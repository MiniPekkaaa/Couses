require('dotenv').config();
const express = require('express');
const Redis = require('redis');
const cors = require('cors');
const TelegramBot = require('node-telegram-bot-api');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Redis клиент
const redisClient = Redis.createClient({
  url: process.env.REDIS_URL
});

// Telegram бот
const bot = new TelegramBot(process.env.TELEGRAM_BOT_TOKEN, { polling: true });

// Подключение к Redis
redisClient.connect().catch(console.error);

// API endpoints
app.get('/api/categories', async (req, res) => {
  try {
    const categories = await redisClient.hGetAll('categories');
    res.json(categories);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/courses', async (req, res) => {
  try {
    const courses = await redisClient.hGetAll('courses');
    res.json(courses);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/lessons', async (req, res) => {
  try {
    const lessons = await redisClient.hGetAll('lessons');
    res.json(lessons);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Административные endpoints
app.post('/api/admin/categories', async (req, res) => {
  try {
    const { id, title, description, image } = req.body;
    await redisClient.hSet(`categories:${id}`, {
      title,
      description,
      image
    });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/admin/courses', async (req, res) => {
  try {
    const { id, title, instructor, image, duration, likes, price, categoryId } = req.body;
    await redisClient.hSet(`courses:${id}`, {
      title,
      instructor,
      image,
      duration,
      likes,
      price,
      categoryId
    });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/admin/lessons', async (req, res) => {
  try {
    const { id, name, duration, video, description, courseId } = req.body;
    await redisClient.hSet(`lessons:${id}`, {
      name,
      duration,
      video,
      description,
      courseId
    });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Запуск сервера
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
}); 