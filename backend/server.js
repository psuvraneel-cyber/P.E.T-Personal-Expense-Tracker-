import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { GoogleGenerativeAI } from '@google/generative-ai';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || '');

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.post('/copilot', async (req, res) => {
  try {
    const { message, context } = req.body || {};
    if (!message) {
      return res.status(400).json({ error: 'Missing message' });
    }

    const system =
      'You are a personal finance copilot for an SMS-based expense tracker. ' +
      'Be concise, explainable, and avoid sensitive advice. Provide 2-3 bullet tips.';

    const userPrompt =
      `User question: ${message}\n` +
      `Context (non-sensitive): ${JSON.stringify(context || {})}`;

    const model = genAI.getGenerativeModel({
      model: process.env.GEMINI_MODEL || 'gemini-1.5-flash',
      systemInstruction: system,
    });

    const response = await model.generateContent(userPrompt);
    const content = response?.response?.text() || 'No response.';
    return res.json({ reply: content });
  } catch (error) {
    return res.status(500).json({ error: 'Copilot failed' });
  }
});

const port = Number(process.env.PORT || 8080);
app.listen(port, () => {
  console.log(`Premium backend listening on ${port}`);
});
