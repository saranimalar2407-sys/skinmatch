const express = require('express');
const router = express.Router();
const skinDataController = require('../controllers/skinDataController');

router.post('/', skinDataController.saveSkinData);
router.get('/:userId', skinDataController.getSkinDataByUser);

module.exports = router;
