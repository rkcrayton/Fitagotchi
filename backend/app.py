
from flask import Flask, jsonify, request
from model import Pet, User
import os
import json
from flask_cors import CORS
from waitress import serve

# my_pet = Pet("BuffDoggo")

DATA_FILE = 'data/user.json'
user_data = {}

if os.path.exists(DATA_FILE):
    with open(DATA_FILE, 'r') as f:
        try:
            raw_data = json.load(f)
            for user_id, data in raw_data.items():
                user_data[user_id] = User.from_dict(data)
        except json.JSONDecodeError:
            pass

app = Flask(__name__)
CORS(app)


my_pet = Pet.load()


@app.route('/')
def home():  # put application's code here
    return jsonify({"message": "Fitagotchi server is live!"})


@app.route('/pet', methods=['GET'])
def get_pet_status():
    user_id = request.args.get('user_id')
    if user_id not in user_data:
        print("➕ Creating new user...")
        user_data[user_id] = User(user_id)

        # Save immediately so it persists
        with open(DATA_FILE, 'w') as f:
            json.dump({uid: u.to_dict() for uid, u in user_data.items()}, f, indent=2)
    return jsonify(user_data[user_id].pet.get_status())


@app.route('/pet/update', methods=['POST'])
def update_pet():
    data = request.get_json()

    user_id = data.get("user_id")
    worked_out = data.get("worked_out_today")

    if not user_id or worked_out is None:
        return jsonify({"error": "Missing 'user_id' or 'worked_out_today'"}), 400

    if user_id not in user_data:
        print(f"Creating new user: {user_id}")
        user_data[user_id] = User(user_id)

    user = user_data[user_id]
    user.pet.update_status(worked_out_today=worked_out)

    # FORCE file creation
    try:
        print("Saving to users.json...")
        with open(DATA_FILE, 'w') as f:
            json.dump(
                {uid: u.to_dict() for uid, u in user_data.items()},
                f,
                indent=2
            )
        print("✔️ File written: data/users.json")
    except Exception as e:
        print("❌ Failed to save file:", e)

    return jsonify(user.pet.get_status())


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5050 , debug=True)
