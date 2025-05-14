from flask import Flask, redirect, request, jsonify
import redis

app = Flask(__name__)

# Настройки Redis
redis_client = redis.Redis(
    host='46.101.121.75',
    port=6379,
    password='otlehjoq',
    decode_responses=True
)

# Редирект на основной сайт
@app.route('/')
def index():
    return redirect('https://school-life-app.stage.3r.agency', code=302)

# Проверка регистрации пользователя
@app.route('/api/check_user')
def check_user():
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'error': 'user_id required'}), 400
    key = f'sc-life:user:{user_id}'
    if redis_client.exists(key):
        return '1', 200
    else:
        return '0', 200

# Получение всех данных пользователя (в том числе Open courses)
@app.route('/api/get_user')
def get_user():
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'error': 'user_id required'}), 400
    key = f'sc-life:user:{user_id}'
    if redis_client.exists(key):
        return jsonify(redis_client.hgetall(key)), 200
    else:
        return jsonify({'error': 'not found'}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003) 