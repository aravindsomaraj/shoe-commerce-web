import streamlit as st
import psycopg2
import time

# Connect to your PostgreSQL database
conn = psycopg2.connect(
    database="shoe",
    user="customer",
    password="newton_issac",
    host="localhost",
    port="5432"
)

cur = conn.cursor()

def check_out (customer_id):
    
    cur.execute("select * from purchase_cart(%s)", (customer_id,))
    status = cur.fetchall()
    conn.commit()

    st.success ("Order Placed")
    time.sleep(1)
    st.experimental_rerun()



def remove_from_cart (customer_id, inventory_id):
    cur.execute("DELETE FROM cart WHERE customer_id = %s and inventory_id = %s", (customer_id, inventory_id))
    conn.commit ()
    st.experimental_rerun()

def view_cart ():
    col1, col2 = st.columns ([7.5,1.5])
    with col2:
        if st.button ("Shoe Listing"):
            st.session_state.pages =1
            st.experimental_rerun()

    st.title("Cart")
    if not st.session_state["logged"]:
        st.write("go to login")
    else:
        if st.session_state["is_customer"]:
            if "user_id" in st.session_state :
                customer_id = st.session_state["user_id"]
                cur.execute("SELECT  p_invetory_id , p_quantity , p_shoe_name , p_brand_name, p_shoe_type , p_price , img_url from view_cart(%s)",(customer_id,))
                products = cur.fetchall()
        else:
            st.write ("should be a customer to see a cart")

    total = 0
    for product in products:
        total += product[5]
    
    col1, col2 = st.columns([8, 1])
    with col2:
        st.write(f"Total: ${total}")


    for product in products:
        col1, col2 = st.columns([1, 2])
        with col1:
            st.image(product[6], width=200)
        with col2:
            product_info_url = f"http://localhost:8501/product_info?inventory_id={product[0]}"
            product_link = f"[{product[2]}]({product_info_url})"
            st.markdown(product_link, unsafe_allow_html=True)
            
            st.write(product[3])
            # st.write( "Type: ",product[4])
            st.write(f"Price: ${product[5]}")
            st.write(f"Quantity: {product[1]}")
            if st.button  ("Remove",key = str(product[0])):
                remove_from_cart(st.session_state.user_id,product[0])
            st.write("---")
    
    col1, col2 = st.columns ([7.6,1.4])
    with col2:
        if(len(products)>0):
            if st.button("Check Out") :
                check_out(st.session_state.user_id)

if __name__ == "__main__":
    view_cart()

    