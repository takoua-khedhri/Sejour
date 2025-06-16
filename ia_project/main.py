from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
import pickle
import face_recognition
import numpy as np
from collections import defaultdict
from sklearn.cluster import DBSCAN
import cv2
import json
import shutil
import random
from concurrent.futures import ThreadPoolExecutor
from fastapi_cache import FastAPICache
from fastapi_cache.backends.redis import RedisBackend
from fastapi_cache.decorator import cache
from redis import asyncio as aioredis
import asyncio
import requests
from io import BytesIO
from fastapi import HTTPException
# Initialisation de l'application FastAPI
app = FastAPI()

# Configurations optimisées
OPTIM_CONFIG = {
    'sample_rate': 5,
    'batch_size': 5,
    'timeout': 1.0,
    'min_face_size': 80,
    'low_res_scale': 0.2,
    'fallback_sample_rate': 8,
    'max_images': 30
}

TURBO_CONFIG = {
    'sample_rate': 10,
    'max_checks': 3,
    'min_face_size': 50,
    'resize_factor': 0.2
}

# Variables globales pour le cache
CHILD_ENCODING = None
IMAGE_CACHE = []

# Modèle Pydantic pour les réponses
class ResponseMessage(BaseModel):
    message: str

# Configuration du cache Redis et préchargement
@app.on_event("startup")
async def startup():
    # Redis
    redis = aioredis.from_url("redis://localhost:6379")
    FastAPICache.init(RedisBackend(redis), prefix="faceapi-cache")
    
    # Préchargement des données
    if os.path.exists("child_embedding.pkl"):
        with open("child_embedding.pkl", "rb") as f:
            global CHILD_ENCODING
            CHILD_ENCODING = pickle.load(f)
    
    # Cache de la liste d'images
    refresh_image_cache()

def refresh_image_cache():
    global IMAGE_CACHE
    if os.path.exists("images"):
        IMAGE_CACHE = [
            f for f in os.listdir("images") 
            if f.lower().endswith((".jpg", ".png"))
        ]

# Nettoyage du dossier uploads/
def clean_uploads():
    folder = 'uploads/'
    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        if os.path.isfile(file_path):
            os.remove(file_path)

# Endpoint /encode-child (inchangé)
@app.post("/encode-child", response_model=ResponseMessage)
async def encode_child():
    folder = "favorites"
    if not os.path.exists(folder):
        raise HTTPException(status_code=400, detail="Dossier 'favorites' introuvable.")

    encodings = []
    for filename in list(os.listdir(folder))[:10]:
        if filename.lower().endswith((".jpg", ".png")):
            path = os.path.join(folder, filename)
            image = face_recognition.load_image_file(path)
            faces = face_recognition.face_encodings(image)
            if faces:
                encodings.extend(faces)

    if not encodings:
        raise HTTPException(status_code=400, detail="Aucun visage détecté dans favorites.")

    if len(encodings) == 1:
        child_encoding = encodings[0]
    else:
        X = np.array(encodings)
        clt = DBSCAN(metric="euclidean", eps=0.6, min_samples=1)
        labels = clt.fit_predict(X)
        dominant_label = np.argmax(np.bincount(labels[labels != -1]))
        child_encoding = X[labels == dominant_label][0]

    with open("child_embedding.pkl", "wb") as f:
        pickle.dump(child_encoding, f)
    
    global CHILD_ENCODING
    CHILD_ENCODING = child_encoding

    clean_uploads()
    return {"message": "Empreinte faciale enregistrée avec succès."}

# Endpoint original optimisé
@app.get("/match-images", response_model=dict)
@cache(expire=3600)
async def match_images_only():
    """Endpoint original optimisé"""
    if CHILD_ENCODING is None:
        raise HTTPException(status_code=404, detail="Appelez /encode-child d'abord.")

    result = {"images": []}
    
    try:
        result["images"] = await asyncio.wait_for(
            process_images_only(CHILD_ENCODING),
            timeout=10  # Timeout réduit
        )
    except asyncio.TimeoutError:
        result["images"] = await quick_fallback_scan(CHILD_ENCODING)

    with open("image_results.json", "w") as f:
        json.dump(result, f)

    return result





@app.post("/match-urls")  # Changez à POST car nous envoyons des données
async def match_image_urls(urls: list[str]):  # Accepte une liste d'URLs en entrée
    """Nouvel endpoint pour le matching avec URLs"""
    if CHILD_ENCODING is None:
        raise HTTPException(
            status_code=400,
            detail="Veuillez d'abord encoder un visage via /encode-child"
        )

    if not urls:
        return {"matches": []}

    matches = []
    
    for url in urls[:20]:  # Limitez le nombre d'URLs pour éviter les timeouts
        try:
            # Téléchargement sécurisé avec timeout
            response = requests.get(
                url,
                stream=True,
                timeout=5,
                headers={'User-Agent': 'FaceMatching/1.0'}
            )
            
            if response.status_code == 200:
                # Chargement de l'image
                image = face_recognition.load_image_file(BytesIO(response.content))
                
                # Détection des visages
                face_locations = face_recognition.face_locations(image)
                if not face_locations:
                    continue
                
                # Encodage du premier visage détecté
                encodings = face_recognition.face_encodings(image, [face_locations[0]])
                if encodings:
                    # Comparaison avec le visage de référence
                    match = face_recognition.compare_faces(
                        [CHILD_ENCODING], 
                        encodings[0], 
                        tolerance=0.6
                    )[0]
                    if match:
                        matches.append(url)
                        
        except Exception as e:
            print(f"Erreur traitement {url}: {str(e)}")
            continue

    return {"matches": matches}


# Nouvel endpoint ultra-rapide
@app.get("/turbo-match", response_model=dict)
async def turbo_match():
    """Endpoint ultra-rapide avec échantillonnage aléatoire"""
    if CHILD_ENCODING is None:
        return {"images": []}

    if not IMAGE_CACHE:
        refresh_image_cache()
        if not IMAGE_CACHE:
            return {"images": []}

    selected = random.sample(IMAGE_CACHE, min(TURBO_CONFIG['max_checks'], len(IMAGE_CACHE)))
    result = []

    for img_name in selected:
        try:
            img_path = os.path.join("images", img_name)
            img = cv2.imread(img_path, cv2.IMREAD_REDUCED_GRAYSCALE_4)
            if img is None:
                continue

            rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            faces = face_recognition.face_locations(rgb, model="hog")
            if not faces:
                continue

            encodings = face_recognition.face_encodings(rgb, [faces[0]])
            if encodings and face_recognition.compare_faces([CHILD_ENCODING], encodings[0], tolerance=0.7)[0]:
                result.append(img_name)
                break  # Stop au premier match

        except Exception as e:
            print(f"Turbo error on {img_name}: {str(e)}")
            continue

    return {"images": result}

# Fonctions utilitaires (inchangées mais optimisées)
async def process_images_only(reference):
    """Traitement optimisé des images"""
    if not IMAGE_CACHE:
        refresh_image_cache()
    
    selected_images = [
        img for i, img in enumerate(IMAGE_CACHE) 
        if i % OPTIM_CONFIG['sample_rate'] == 0
    ][:OPTIM_CONFIG['max_images']]

    matched_images = []
    
    for i in range(0, len(selected_images), OPTIM_CONFIG['batch_size']):
        batch = selected_images[i:i + OPTIM_CONFIG['batch_size']]
        
        with ThreadPoolExecutor() as executor:
            batch_results = list(executor.map(
                lambda img: process_optimized_image(img, reference),
                batch
            ))
            
            matched_images.extend([img for img in batch_results if img])
            if matched_images and len(matched_images) >= 3:
                break

    return matched_images

def process_optimized_image(filename, reference):
    """Version ultra-optimisée du traitement d'image"""
    try:
        img_path = os.path.join("images", filename)
        img = cv2.imread(img_path)
        if img is None:
            return None
            
        small_img = cv2.resize(img, (0, 0), 
                             fx=OPTIM_CONFIG['low_res_scale'], 
                             fy=OPTIM_CONFIG['low_res_scale'])
        rgb = cv2.cvtColor(small_img, cv2.COLOR_BGR2RGB)
        
        face_locations = face_recognition.face_locations(rgb, model="hog")
        if not face_locations:
            return None
            
        top, _, bottom, _ = face_locations[0]
        if (bottom - top) < OPTIM_CONFIG['min_face_size'] * OPTIM_CONFIG['low_res_scale']:
            return None
            
        encodings = face_recognition.face_encodings(rgb, [face_locations[0]])
        if encodings and face_recognition.compare_faces([reference], encodings[0], tolerance=0.6)[0]:
            return filename
        return None
    except Exception as e:
        print(f"Error processing {filename}: {str(e)}")
        return None

async def quick_fallback_scan(reference):
    """Version accélérée pour fallback"""
    if not IMAGE_CACHE:
        refresh_image_cache()
    
    selected = [
        img for i, img in enumerate(IMAGE_CACHE) 
        if i % OPTIM_CONFIG['fallback_sample_rate'] == 0
    ][:20]
    
    def quick_check(img_path):
        try:
            img = cv2.imread(os.path.join("images", img_path))
            if img is None:
                return False
                
            tiny_img = cv2.resize(img, (0,0), fx=0.1, fy=0.1)
            rgb = cv2.cvtColor(tiny_img, cv2.COLOR_BGR2RGB)
            return bool(face_recognition.face_locations(rgb, model="hog"))
        except:
            return False
    
    with ThreadPoolExecutor() as executor:
        results = list(executor.map(
            lambda img: img if quick_check(img) else None,
            selected
        ))
        return [r for r in results if r]

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)