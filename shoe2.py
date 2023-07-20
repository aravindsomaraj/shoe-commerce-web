from flask import Flask, render_template

app = Flask(__name__)

# dummy data for shoe products
shoe_products = [
    {"name": "Adidas Superstar", "price": 80.00, "image": "https://via.placeholder.com/150x150.png?text=Adidas+Superstar"},
    {"name": "Nike Air Max 270", "price": 150.00, "image": "https://via.placeholder.com/150x150.png?text=Nike+Air+Max+270"},
    {"name": "New Balance 990v5", "price": 175.00, "image": "https://via.placeholder.com/150x150.png?text=New+Balance+990v5"},
    {"name": "Vans Old Skool", "price": 60.00, "image": "https://via.placeholder.com/150x150.png?text=Vans+Old+Skool"},
    {"name": "Converse Chuck Taylor", "price": 50.00, "image": "https://via.placeholder.com/150x150.png?text=Converse+Chuck+Taylor"},
]

@app.route('/')
def index():
    return render_template('shoe2.html', shoes=shoe_products)

if __name__ == '__main__':
    app.run()
