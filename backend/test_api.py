import requests
import json

BASE_URL = "http://localhost:5000/api"

def test_auth():
    print("Testing Auth...")
    # Signup
    signup_data = {
        "username": "testuser",
        "email": "test@example.com",
        "password": "Password123!"
    }
    r = requests.post(f"{BASE_URL}/auth/signup", json=signup_data)
    print(f"Signup: {r.status_code}")
    print(r.json())

    # Login
    login_data = {
        "email": "test@example.com",
        "password": "Password123!"
    }
    r = requests.post(f"{BASE_URL}/auth/login", json=login_data)
    print(f"Login: {r.status_code}")
    print(r.json())
    return r.json().get('token')

def test_products():
    print("\nTesting Products...")
    r = requests.get(f"{BASE_URL}/products")
    print(f"Get Products: {r.status_code}")
    print(r.json())

if __name__ == "__main__":
    try:
        token = test_auth()
        test_products()
    except Exception as e:
        print(f"Error: {e}")
