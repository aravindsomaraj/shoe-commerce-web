
import streamlit as st
import psycopg2
import time

# from streamlit_extras.switch_page_button import switch_page
# from streamlit_option_menu import option_menu



# Connect to the PostgreSQL database
conn = psycopg2.connect(
    database="shoe",
    user="seller",
    password="dont_have_any_idea",
    host="localhost",
    port="5432"
)


cur = conn.cursor()

# st.session_state["login_status"] = True
# st.session_state["is_customer"] = False
# st.session_state["is_seller"] = True
# st.session_state["user_id"]  = 5
# seller_id = st.session_state["user_id"]
# cur.execute("SELECT p_brand_name, p_shoe_name, p_shoe_type, p_price, p_rating, p_image_url, p_shoe_id, p_inventory_id , p_seller_id, p_quantity   from view_seller_inventory(%s)",(seller_id,))
# products = cur.fetchall()

def delete_inventory( inventory_id , seller_id):
    cur.execute("SELECT * FROM remove_inventory (%s, %s)", (inventory_id,seller_id))
    result = cur.fetchall()
    conn.commit()
    if result[0][0] == 0 :
        print("We should not be here")
    st.session_state.seller_state = 0
    st.experimental_rerun()


def update_app( inve_id , p_shoe_id , p_seller_id , p_quantity , p_price ):
    #  p_shoe_size , p_location , p_status 
    p_shoe_size = st.text_input("Shoe size")
    p_location = st.text_input("Location")
    p_status = st.text_input("Status")
    p_quantity = st.text_input("Quantity")
    p_price = st.number_input("Price")
        
    if st.button("Complete"):
        updating(inve_id , p_shoe_id , p_seller_id , p_quantity , p_price,  p_shoe_size , p_location , p_status)
        
    if st.button("Back"):
        st.session_state.seller_page = 0
        st.experimental_rerun()


def updating(inve_id , p_shoe_id , p_seller_id , p_quantity , p_price,  p_shoe_size , p_location , p_status):
    cur.execute("SELECT * FROM update_inventory (%s, %s, %s, %s, %s, %s, %s, %s)", (inve_id , p_shoe_id , p_seller_id , int(p_shoe_size) , int(p_quantity) , p_price, p_location , p_status))
    result = cur.fetchall()
    conn.commit()
    st.session_state.seller_page = 0
    st.experimental_rerun()
    
    
def add_inventory():
    
    st.title("Add inventory")
    
    
    cur.execute("SELECT shoe_name FROM shoe")
    nameList = cur.fetchall()
    
    namelist = [str(name[0]) for name in nameList]

    p_shoe_name = st.selectbox("Shoe Name",namelist)
    p_shoe_name = str(p_shoe_name)
    # st.write(p_shoe_name)

    cur.execute("SELECT shoe_id FROM shoe_names WHERE shoe_name = '" + str(p_shoe_name) + "'")
    
    p_shoe_id = cur.fetchall()
    # st.write(p_shoe_id[0][0])
    shoe_id = p_shoe_id[0][0]

    p_shoe_size = st.text_input("Shoe size")
    p_location = st.text_input("Location")
    p_status = st.text_input("Status")
    p_quantity = st.text_input("Quantity")
    p_price = st.number_input("Price")
    
    seller_id = st.session_state["user_id"]
    
    if st.button("Add inventory"):
        cur.execute("SELECT * FROM insert_inventory(%s, %s, %s, %s, %s, %s, %s)",(shoe_id, seller_id, p_shoe_size , p_quantity, p_price, p_location, p_status))
        result = cur.fetchall()
        conn.commit()

        st.session_state.seller_page = 0
        st.experimental_rerun()

    if st.button("Back"):
        st.session_state.seller_page = 0
        st.experimental_rerun()


def seller_orders_page():
    st.title("Orders")
    
    if st.button("Back"):
        st.session_state.seller_page = 0
        st.experimental_rerun()
    
    seller_id = st.session_state["user_id"]
    
    cur.execute("SELECT *  FROM orders join inventory using(inventory_id) WHERE seller_id = %s",(seller_id,))
    products = cur.fetchall()
    
    
    for product in products:
        
        
            product_info_url = f"http://localhost:8501/product_info?inventory_id={product[0]}"
            product_link = f"[{product[0]}]({product_info_url})"
            st.markdown(product_link, unsafe_allow_html=True)
            
            # st.write("Order id: ",product[0])
            # st.write("Inventory id: ",product[1])
            st.write("Quantity: ",product[-5])
            st.write("Status: ",product[2])
            newStatus = st.text_input("New status",product[2], key= str(product[1]))
            st.write( "Address: " , product[8])
            st.write( "customer id: ", product[5])
            st.write("Order date: ", product[6])
            st.write("Disatch date: ", product[3])
            dispatchDate = st.text_input("Update dispatch date",product[3], key="dis"+str(product[1]))
            st.write("Delivery date: ", product[4])
            deliveryDate = st.text_input("Update delivery date",product[4], key="del"+str(product[1]))
            
            if st.button("Update", key = "b"+str(product[1])):
                if (dispatchDate == 'None'):
                    cur.execute("UPDATE orders SET order_status = %s WHERE order_id = %s", ( newStatus , product[1] ))
                elif (deliveryDate == 'None'):                    
                    cur.execute("UPDATE orders SET order_status = %s, dispatch_date = %s WHERE order_id = %s", ( newStatus , dispatchDate , product[1] ))
                else:
                    cur.execute("UPDATE orders SET order_status = %s, delivery_date = %s, dispatch_date = %s WHERE order_id = %s", ( newStatus , deliveryDate , dispatchDate , product[1] ))
                conn.commit ()
                st.success("Updated!")
                time.sleep(1)
                st.experimental_rerun()
            st.write("---")
    


def view_seller_inventory ():

    col1, col2, col3,col4  = st.columns ([4,2,2.1,1.4])
    with col2:
        if st.button("Order details"):
            st.session_state.seller_page = 3
            st.experimental_rerun()

    with col3:
        if st.button("Add inventory"):
            st.session_state.seller_page = 2
            st.experimental_rerun()
            # add_inventory()
    with col4: 

        if st.button ("Logout"):
            st.session_state.login_status = False
            st.session_state.pages = 0
            st.session_state.page = 1
            st.experimental_rerun()

    st.title("Inventory")
    if not st.session_state["login_status"]:
        st.write("go to login")
    else:
        if st.session_state["is_seller"]:
            if "user_id" in st.session_state :
                seller_id = st.session_state["user_id"]
                cur.execute("SELECT p_brand_name, p_shoe_name, p_shoe_type, p_price, p_rating, p_image_url, p_shoe_id, p_inventory_id , p_seller_id, p_quantity   from view_seller_inventory(%s)",(seller_id,))
                products = cur.fetchall()
        else:
            st.write ("should be a seller to see inventory")
    
    

    for product in products:
        col1, col2 = st.columns([1, 2])
        with col1:
            st.image(product[5], width=200)
        with col2:
            product_info_url = f"http://localhost:8501/product_info?inventory_id={product[7]}"
            product_link = f"[{product[1]}]({product_info_url})"
            st.markdown(product_link, unsafe_allow_html=True)
            
            st.write(product[0])
            # st.write( "Type: ",product[2])
            st.write(f"Price: ${product[3]}")
            st.write(f"Rating: {product[4]}")
            st.write(f"Quantity: {product[9]}")
            col3, col4 = st.columns([1, 1])
            with col3:
                if st.button("Update", key="u"+str(product[7])):
                    st.session_state.seller_page = 1
                    st.experimental_rerun()
                    update_app(product[7], product[6] , seller_id , product[8] , product[3] )
            with col4:
                if st.button("Delete", key="d"+str(product[7])):
                    delete_inventory( product[7],seller_id)
                    
            st.write("---")


def main ():
    if "seller_page" not in st.session_state:
        st.session_state.seller_page = 0

    seller_id = st.session_state["user_id"]
    cur.execute("SELECT p_brand_name, p_shoe_name, p_shoe_type, p_price, p_rating, p_image_url, p_shoe_id, p_inventory_id , p_seller_id, p_quantity   from view_seller_inventory(%s)",(seller_id,))
    products = cur.fetchall()



    if st.session_state.seller_page == 0:
        view_seller_inventory()
    elif st.session_state.seller_page == 1:
        update_app(products[0][7], products[0][6] , seller_id , products[0][8] , products[0][3] )
    elif st.session_state.seller_page == 2:
        add_inventory()
    elif st.session_state.seller_page == 3:
        seller_orders_page()

# if __name__ == "__main__":
    
#     if "seller_page" not in st.session_state:
#         st.session_state.seller_page = 0
        
#     if st.session_state.seller_page == 0:
#         view_seller_inventory()
#     elif st.session_state.seller_page == 1:
#         update_app(products[0][7], products[0][6] , seller_id , products[0][8] , products[0][3] )
#     elif st.session_state.seller_page == 2:
#         add_inventory()
#     elif st.session_state.seller_page == 3:
#         seller_orders_page()
    
    # elif st.session_state.page == -1:
     #    update_app()

