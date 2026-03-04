const SkinData = require('../models/SkinData');

exports.saveSkinData = async (req, res) => {
    try {
        const { userId, fullName, age, gender, skinType, undertone, shadeLevel } = req.body;
        const skinData = new SkinData({ userId, fullName, age, gender, skinType, undertone, shadeLevel });
        await skinData.save();
        res.status(201).json(skinData);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.getSkinDataByUser = async (req, res) => {
  try {
    const data = await SkinData.findOne({ userId: req.params.userId });

    if (!data) {
      return res.status(404).json({ message: "No data found" });
    }

    res.json(data);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};