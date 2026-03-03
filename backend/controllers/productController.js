const Product = require('../models/Product');

exports.getProducts = async (req, res) => {
    try {
        const undertone = req.query.undertone;
        let query = {};
        if (undertone) {
            query.undertone = new RegExp(undertone, 'i');
        }
        const products = await Product.find(query);
        res.json(products);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.createProduct = async (req, res) => {
    try {
        const product = new Product(req.body);
        await product.save();
        res.status(201).json(product);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
