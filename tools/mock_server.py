from flask import Flask, request, jsonify

app = Flask(__name__)


@app.post("/v1/chat/completions")
def chat():
    _ = request.json or {}
    # Renvoie un contenu conforme à la forme attendue par l'app:
    # choices[0].message.content doit être une chaîne contenant un JSON strict
    mock_json = {
        "translation": "MOCK: réponse ok",
        "pinyin": None,
        "notes": None,
    }
    return jsonify({
        "choices": [
            {"message": {"content": jsonify(mock_json).get_data(as_text=True)}}
        ]
    })


if __name__ == "__main__":
    # Écoute sur 0.0.0.0:3000
    app.run(host="0.0.0.0", port=3000)


