require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const multer = require('multer');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

const UPLOAD_DIR = path.join(__dirname, 'uploads');
if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, UPLOAD_DIR);
  },
  filename: function (req, file, cb) {
    const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, unique + '-' + file.originalname.replace(/[^a-zA-Z0-9.\-]/g, '_'));
  }
});

const upload = multer({ storage });

// JWT utility functions
const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '7d' });
};

const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.userId = decoded.userId;
    next();
  });
};

const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/dog_tinder_dev';
console.log('Attempting to connect to MongoDB...');

mongoose.connect(mongoUri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 5000, // Timeout after 5s instead of 30s
  connectTimeoutMS: 10000, // Give up initial connection after 10 seconds
})
.then(() => console.log('Successfully connected to MongoDB'))
.catch(err => {
  console.error('MongoDB connection error:', {
    message: err.message,
    code: err.code,
    reason: err.reason
  });
  process.exit(1); // Exit if we can't connect to the database
});

const userSchema = new mongoose.Schema({
  dogName: String,
  email: { type: String, unique: true, index: true },
  passwordHash: String,
  birthdate: Date,
  description: String,
  imagePath: String,
}, { timestamps: true });

const User = mongoose.model('User', userSchema);

app.post('/api/register', upload.single('dogImage'), async (req, res) => {
  try {
    console.log('Received registration request:', {
      body: req.body,
      file: req.file ? { 
        filename: req.file.filename,
        size: req.file.size,
        mimetype: req.file.mimetype
      } : null
    });

    const { dogName, email, password, birthdate, description } = req.body;
    if (!dogName || !email || !password || !birthdate || !description || !req.file) {
      console.log('Missing fields:', { dogName, email, birthdate, description, hasFile: !!req.file });
      return res.status(400).json({ error: 'Missing fields' });
    }

    const existing = await User.findOne({ email });
    if (existing) return res.status(409).json({ error: 'Email already registered' });

    const passwordHash = await bcrypt.hash(password, 10);
    const user = new User({
      dogName,
      email,
      passwordHash,
      birthdate: new Date(birthdate),
      description,
      imagePath: req.file.filename,
    });

    console.log('Attempting to save user:', {
      dogName: user.dogName,
      email: user.email,
      birthdate: user.birthdate,
      imagePath: user.imagePath
    });

    await user.save();

    // Generate JWT token
    const token = generateToken(user._id);

    return res.json({ 
      success: true, 
      token,
      user: { 
        id: user._id, 
        dogName: user.dogName, 
        email: user.email, 
        birthdate: user.birthdate, 
        description: user.description, 
        imagePath: user.imagePath 
      } 
    });
  } catch (err) {
    console.error('Registration error details:', {
      message: err.message,
      code: err.code,
      stack: err.stack
    });
    return res.status(500).json({ error: err.message || 'Server error' });
  }
});

app.post('/api/login', express.urlencoded({ extended: true }), async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ error: 'Missing fields' });

    const user = await User.findOne({ email });
    if (!user) return res.status(401).json({ error: 'Invalid credentials' });

    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) return res.status(401).json({ error: 'Invalid credentials' });

    // Generate JWT token
    const token = generateToken(user._id);

    return res.json({ 
      success: true, 
      token,
      user: { 
        id: user._id, 
        dogName: user.dogName, 
        email: user.email, 
        birthdate: user.birthdate, 
        description: user.description, 
        imagePath: user.imagePath 
      } 
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.use('/uploads', express.static(UPLOAD_DIR));

const port = process.env.PORT || 3000;
app.listen(port, () => console.log('Server listening on port', port));
