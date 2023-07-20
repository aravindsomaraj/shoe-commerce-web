import streamlit as st
import psycopg2
from streamlit_extras.switch_page_button import switch_page


# Connect to the PostgreSQL database
conn = psycopg2.connect(
    database="shoe",
    user="customer",
    password="newton_issac",
    host="localhost",
    port="5432"
)

if st.button ("go back"):
    switch_page ("shoe_streamlit")

# Retrieve the product ID from the URL
inventory_id = st.experimental_get_query_params().get("inventory_id")
if inventory_id:
    inventory_id = inventory_id[0]
else:
    st.error("Product ID not found in URL.")
    st.stop()

# Retrieve product information from the PostgreSQL table based on the ID
cur = conn.cursor()
# cur.execute("SELECT shoe_name, shoe_type, brand_id,shoe_id,image_url FROM shoe WHERE shoe_id=%s", (product_id,))
cur.execute("SELECT p_shoe_name, p_brand_name, p_shoe_size, p_price, p_image_url,p_shoe_color, p_status, p_quantity, p_shoe_type, p_rating FROM shoe_details(%s)", (inventory_id,))
product_info = cur.fetchone()

# Display the product information
if product_info:
    name = product_info[0]
    brand = product_info[1]
    size = product_info[2]
    price = product_info[3]
    image_url = product_info[4]
    color = product_info[5]
    status = product_info[6]
    quantity = product_info[7]
    type = product_info[8]
    rating = product_info[9]

    st.title(name)
    col1, col2 = st.columns([2, 1])
    with col1:
        st.image(image_url, width=400)
    with col2:
        st.write(brand)
        st.write(f"Price: ${price}")
        st.write(f"Colors: "+color)
        st.write(f"Type: {type}")
        st.write(f"Size: {size}")

        if(rating != None):
            st.write(f"Rating:  {rating}" )
        
        if(quantity >= 10):
            st.write("In stock")
        elif (quantity == 0):
            st.write("Out of Stock")
        else:
            st.write(f"Only {quantity} pairs remaining.")

else:
    st.error("Product not found.")
