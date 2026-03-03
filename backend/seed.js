const mongoose = require('mongoose');
const Product = require('./models/Product');
const dotenv = require('dotenv');

dotenv.config();

const products = [
    {
        brand: "Maybelline",
        name: "Fit Me Matte + Poreless",
        finish: "Liquid • Matte",
        undertone: "Neutral",
        price: "₹499",
        imageUrl: "https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=800&q=80"
    },
    {
        brand: "L'Oréal Paris",
        name: "Infallible Fresh Wear",
        finish: "Liquid • Longwear",
        undertone: "Warm",
        price: "₹899",
        imageUrl: "https://images.unsplash.com/photo-1611930022073-b7a4ba5fcccd?auto=format&fit=crop&w=800&q=80"
    },
    {
        brand: "M·A·C",
        name: "Studio Fix Fluid",
        finish: "Liquid • Matte",
        undertone: "Cool",
        price: "₹3499",
        imageUrl: "https://cdn.mos.cms.futurecdn.net/7q6rQ7uHYTMU328YB4KNEP.jpg"
    }
];

mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/skinmatch')
    .then(async () => {
        console.log('Connected to MongoDB for seeding...');
        await Product.deleteMany({});
        await Product.insertMany(products);
        console.log('Seeded products successfully!');
        mongoose.connection.close();
    })
    .catch(err => console.log(err));
