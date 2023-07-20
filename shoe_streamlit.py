import streamlit as st
import psycopg2
from streamlit_extras.switch_page_button import switch_page
import login

# Connect to the PostgreSQL database
conn = psycopg2.connect(
    database="shoe",
    user="customer",
    password="newton_issac",
    host="localhost",
    port="5432"
)

cur = conn.cursor()

def add_to_cart (inventory_id,customer_id):
    if st.session_state.login_status:
        cur.execute("SELECT * FROM add_to_cart(%s,%s)",(customer_id, inventory_id))
        result = cur.fetchall()
        conn.commit()
        st.write("Added.")
    else:
        st.session_state.pages = 1
        st.experimental_rerun()

def app(userID,is_Cust):

    st.session_state.is_customer = is_Cust
    if userID != None:
        st.session_state.login_status = True
    if st.session_state.login_status == False:
        col1, col2 = st.columns([8, 1])
        with col2:
            if st.button ("Login "):
                st.session_state.pages = 1
                st.experimental_rerun()
    else:
        col1,col2 = st.columns ([8,1])
        with col2:
            # cur.execute("")
            st.write(f"User - {userID}")
        col1,col2,col3,col4 = st.columns ([5.6,1.2,1,1.4])
        with col3:
            if st.button("Cart"):
                st.session_state.pages = 3
                st.experimental_rerun()
        with col2: 
            if st.button("Orders") :
                st.session_state.pages = 4
                st.experimental_rerun()
        with col4:
            if st.button("Logout"):
                st.session_state.login_status = False
                st.session_state.pages = 0
                st.session_state.page = 1
                st.experimental_rerun()

    # Retrieve product information from the PostgreSQL table
    cur.execute("SELECT brand_name,shoe_name, shoe_type, price, rating,image_url,shoe_id, inventory_id FROM shoe_list")
    products = cur.fetchall()

    # Create the Streamlit web interface
    st.title("Shoe Listing")

    # Create the search bar and filter options
    search = st.text_input("Search Products")
    st.sidebar.title("Filter Options")
    filter_price = st.sidebar.selectbox("Filter by Price", ["All", "$0 - $50", "$50 - $100", "$100 - $500"])
    sort_by = st.sidebar.selectbox("Sort by", ["Name", "Price (Low to High)", "Price (High to Low)"])

    # Filter the products based on the user's selected options
    filtered_products = []
    for product in products:
        if search.lower() in product[1].lower() or search.lower() in product[0].lower() or search == "":
            if filter_price == "All" or (filter_price == "$0 - $50" and product[3] <= 50) or (filter_price == "$50 - $100" and 50 < product[3] <= 100) or (filter_price == "$100 - $500" and product[3] > 100):
                filtered_products.append(product)

    # Sort the filtered products based on the user's selected option
    if sort_by == "Name":
        filtered_products.sort(key=lambda x: x[1])
    elif sort_by == "Price (Low to High)":
        filtered_products.sort(key=lambda x: x[3])
    else:
        filtered_products.sort(key=lambda x: x[3], reverse=True)

    for product in filtered_products:
        col1, col2 = st.columns([1, 2])
        with col1:
            st.image(product[5], width=200)
        with col2:
            product_info_url = f"http://localhost:8501/product_info?inventory_id={product[7]}"
            product_link = f"[{product[0]}]({product_info_url})"
            st.markdown(product_link, unsafe_allow_html=True)
            
            col3,col4 = st.columns([3, 1])
            with  col3:
                st.write(product[1])
            with col4:
                if (st.button("Add To Cart", key = str(product[7]) )):
                    add_to_cart (product[7],st.session_state.user_id)
            
            st.write( "Type: ",product[2])
            st.write(f"Price: ${product[3]}")
            st.write(f"Rating: {product[4]}")

            st.write("---")

def main():
    if "is_customer" not in st.session_state:
        st.session_state.is_customer = False     
    
    if "login_status" not in st.session_state:
        st.session_state.login_status = False

    if "user_id" not in st.session_state:
        st.session_state.user_id = None

    if "pages" not in st.session_state:
        st.session_state.pages = 0


    if st.session_state.pages == 1:
        import login
        if login.main() == False:
            st.session_state.pages = 0
            st.experimental_rerun()
    elif st.session_state.pages == 3:
        import cart
        cart.view_cart()

    elif st.session_state.login_status == False:
        app(None,False)
    elif st.session_state.login_status == True and st.session_state.pages == 0 and st.session_state.is_customer:
        app(st.session_state.user_id,st.session_state.is_customer)
    elif st.session_state.login_status == True and st.session_state.pages == 0 and not st.session_state.is_customer:
        import seller
        st.session_state["is_seller"] = True
        seller.main()
    elif st.session_state.pages ==4:
        import orders
        orders.view_orders()
    
        

if __name__ == "__main__":
    main()