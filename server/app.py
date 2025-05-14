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
    print(f'[get_user] user_id={user_id}')  # Логируем user_id
    if not user_id:
        print('[get_user] Нет user_id в запросе')
        return jsonify({'error': 'user_id required'}), 400

    key = f'sc-life:user:{user_id}'
    print(f'[get_user] Ищу ключ: {key}')  # Логируем ключ

    if redis_client.exists(key):
        data = redis_client.hgetall(key)
        print(f'[get_user] Данные из Redis: {data}')  # Логируем результат
        return jsonify(data), 200
    else:
        print(f'[get_user] Ключ не найден: {key}')
        return jsonify({'error': 'not found'}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003) 