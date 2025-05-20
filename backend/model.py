import datetime
import json
import os

class User:
    def __init__(self, user_id):
        self.user_id = user_id
        self.pet = Pet("BuffDoggo")

    def to_dict(self):
        return {
            "user_id": self.user_id,
            "pet": self.pet.get_status()
        }

    @classmethod
    def from_dict(cls, data):
        user = cls(data["user_id"])
        pet_data = data.get("pet",{})
        user.pet = Pet(
            name=pet_data.get("name","BuffDoggo"),
            health=pet_data.get("health",100),
            happiness=pet_data.get("happiness",100),
            last_workout_date=pet_data.get("last_workout_date")
        )
        return user

class Pet:
    def __init__(self, name, health=100, happiness=100, last_workout_date=None):
        self.name = name
        self.health = health
        self.happiness = happiness
        self.last_workout_date = (
            datetime.datetime.strptime(last_workout_date, "%Y-%m-%d").date()
            if last_workout_date else None
        )

    def update_status(self, worked_out_today):
        today = datetime.date.today()
        if worked_out_today:
            self.health = min(100, self.health + 10)
            self.happiness = min(100, self.happiness + 10)
            self.last_workout_date = today
        else:
            if self.last_workout_date != today:
                self.health = max(0, self.health - 10)
                self.happiness = max(0, self.happiness - 5)

    def get_status(self):
        return {
            'name': self.name,
            'health': self.health,
            'happiness': self.happiness,
            'last_workout_date': str(self.last_workout_date) if self.last_workout_date else None
        }

    def save(self, path='data/pet.json'):
        with open(path, 'w') as f:
            json.dump(self.get_status(), f)

    @classmethod
    def load(cls, path='data/pet.json'):
        if os.path.exists(path):
            with open(path, 'r') as f:
                try:
                    data = json.load(f)
                    return cls(
                        name=data.get("name", "BuffDoggo"),
                        health=data.get("health", 100),
                        happiness=data.get("happiness", 100),
                        last_workout_date=data.get("last_workout_date")
                    )
                except json.JSONDecodeError:
                    pass

        return cls("BuffDoggo")
