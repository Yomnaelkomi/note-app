const express = require("express");
const dotenv = require("dotenv");
const mongoose = require("mongoose");
const cors = require("cors");

dotenv.config({ path: "./config.env" });
const app = express();
app.use(cors());
app.use(express.json());

// MongoDB Connection
mongoose
  .connect(process.env.DATABASE_LOCAL, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("Connected to MongoDB"))
  .catch((err) => console.error("MongoDB connection error:", err));

// Note Schema and Model
const noteSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, "A note must have a title"],
  },
  description: {
    type: String,
    default: "No description added",
  },
});

const Note = mongoose.model("Note", noteSchema);

// GET: Fetch All Notes
app.get("/api/note", async (req, res) => {
  try {
    const notes = await Note.find();
    res.status(200).json({
      status: "success",
      data: notes,
    });
  } catch (err) {
    res.status(500).json({
      status: "fail",
      message: err.message,
    });
  }
});

// POST: Create a New Note
app.post("/api/note", async (req, res) => {
  try {
    const { title, description } = req.body;

    if (!title) {
      return res.status(400).json({
        status: "fail",
        message: "Title is required",
      });
    }

    const newNote = await Note.create({ title, description });
    res.status(201).json({
      status: "success",
      data: newNote,
    });
  } catch (err) {
    res.status(500).json({
      status: "fail",
      message: err.message,
    });
  }
});

// DELETE: Remove a Note by ID
app.delete("/api/note/:id", async (req, res) => {
  try {
    const note = await Note.findByIdAndDelete(req.params.id);

    if (!note) {
      return res.status(404).json({
        status: "fail",
        message: "Note not found",
      });
    }

    res.status(204).json({
      status: "success",
      data: null,
    });
  } catch (err) {
    res.status(500).json({
      status: "fail",
      message: err.message,
    });
  }
});

// PATCH: Update a Note by ID
app.patch("/api/note/:id", async (req, res) => {
  try {
    const updatedNote = await Note.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    if (!updatedNote) {
      return res.status(404).json({
        status: "fail",
        message: "Note not found",
      });
    }

    res.status(200).json({
      status: "success",
      data: updatedNote,
    });
  } catch (err) {
    res.status(500).json({
      status: "fail",
      message: err.message,
    });
  }
});

// Start Server
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
