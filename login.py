import streamlit as st
import psycopg2
from streamlit_option_menu import option_menu
import shoe_streamlit
import time

# Connect to your PostgreSQL database

conn = psycopg2.connect(
    database="shoe",
    user="customer",
    password="newton_issac",
    host="localhost",
    port="5432"
)


# Define a function that checks if the email and password are valid
def customer_login(email, password):
    cur = conn.cursor()
    cur.execute("SELECT * FROM check_customer_login(%s, %s)", (email, password))
    result = cur.fetchone()
    cur.close()
    if result[0] == 'invalid username':
        errmes = "Username does not exist"
        # st.error("Username does not exist")
    elif result[0] == 'invalid password':
        errmes = "Username and password do not match"
        # st.error("Username and password do not match")
    elif result[0] == 'accept':
        return True, result[1] , ""
    return False, None , errmes
    
def seller_login(email, password):
    cur = conn.cursor()
    cur.execute("SELECT * FROM check_seller_login(%s, %s)", (email, password))
    result = cur.fetchone()
    cur.close()
    if result[0] == 'invalid username':
        errmes = "Username does not exist"
        # st.error("Username does not exist")
    elif result[0] == 'invalid password':
        errmes = "Username and password do not match"
        # st.error("Username and password do not match")
    elif result[0] == 'accept':
        return True, result[1], ""
    return False, None, errmes


def registration_app():

    selected = option_menu(
        menu_title="Registration",
        options=["Customer","Seller"],
        icons=["house","book"],
        default_index=0,
        orientation="horizontal",
    )
    flag = -1
    if selected == "Customer":
        name = st.text_input("Name")
        email = st.text_input("Email")
        password = st.text_input("Password", type="password")
        address = st.text_input("Address")
        number = st.text_input("Number")
        payment_details = st.text_input("Payment Details")
        f=0
        
    elif selected == "Seller":
        name = st.text_input("Name")
        email = st.text_input("Email")
        password = st.text_input("Password", type="password")
        address = st.text_input("Address")
        number = st.text_input("Number")
        f=1
    
    if st.button("Register"):
        cur = conn.cursor()
        if f == 0:
            cur.callproc('insert_customer',[name,email,address,number,payment_details,password])
        elif f == 1:
            cur.callproc('insert_seller',[name,email,address,number,password])
        result = cur.fetchone()[0]
        conn.commit()
        cur.close()

        # Checking return value
        if result == 1:
            st.session_state.page = 1
            st.success("Registration successful")
            time.sleep(2)
            st.experimental_rerun()
        elif result == 2:
            st.error("Email already registered")

    st.button("Already have an account? Log in",on_click=switch)

def switch(): st.session_state.page *= -1
def loggedin(): 
    st.session_state.logged = True
    # print(st.session_state.logged)
    st.session_state.page = 2
    st.experimental_rerun()

def app():
    st.title("Customer Login")
    email = st.text_input("Email")
    password = st.text_input("Password", type="password")
    errmes = ""
    sucmes = ""
    success= ""
    col1, col2 = st.columns([1, 8])
    with col1:
        if st.button("Login"):
            
            success, user_id, errmes = customer_login(email, password)
            st.session_state.is_customer = True
    with col2:
        if st.button("Seller Login"):
            success, user_id, errmes = seller_login(email, password)
            st.session_state.is_customer = False
    if success:
        st.session_state.user_id = user_id
        st.session_state.logged = True
        st.success("Logged in!")
        time.sleep(2)
        # print(st.session_state.logged)
        loggedin()
    if errmes != "":
        st.error(errmes)
    st.button("Not a user?",on_click=switch)

    if st.button ("Quick Login"):
        st.session_state.user_id = 5
        st.session_state.is_customer = True
        
        st.success("Logged in!")
        # time.sleep(2)
        # print(st.session_state.logged)
        loggedin()

# Define the Streamlit app
def main():
    
    if "is_customer" not in st.session_state:
        st.session_state.is_customer = True
    if "user_id" not in st.session_state:
        st.session_state.user_id = None
    if "logged" not in st.session_state:
        st.session_state.logged = False
    if "page" not in st.session_state:
        st.session_state.page = 1

    if st.session_state.page != 2:
        if st.button("Go back"):
            return False
        
    if st.session_state.page == 1:
        app()       
    
    elif st.session_state.page == -1:
        registration_app()

    elif st.session_state.page == 2:
        st.session_state.pages = 0
        st.session_state.login_status = True
        # st.session_state.is_customer = 
        # st.session_state.user_id
        # st.session_state.is_customer 
        st.experimental_rerun()
        # shoe_streamlit.app(st.session_state.user_id,st.session_state.is_customer)
    

if __name__ == '__main__':
    main()
