import streamlit as st
import psycopg2
import pandas as pd

# Connect to the database
conn = psycopg2.connect(
    database="shoe",
    user="buu",
    password="chessiscool",
    host="localhost",
    port="5432"
)

# Define a function to retrieve the orders of the current customer
def get_customer_orders(customer_id):
    # Open a cursor
    cur = conn.cursor()
    cur.execute("SELECT order_id,order_status,customer_id,order_date,order_number,delivery_address,quantity FROM orders WHERE customer_id = %s", (customer_id,))
    orders = cur.fetchall()
    col_names = [desc[0] for desc in cur.description]
    cur.close()

    return col_names,orders

# Define the Streamlit app
def view_orders(customer_id):
    # Set the title of the app
    st.title("Orders Placed")

    # Get the customer ID from the user
    # customer_id = st.number_input("Enter customer ID", value=1, min_value=1)
    st.write(f"Showing orders for customer : {customer_id}")

    # Retrieve the orders for the current customer
    col_names,orders = get_customer_orders(customer_id)

    # Display the orders in a table
    if orders:
        st.write("Orders for customer ID", customer_id)
        orders_df = pd.DataFrame(orders, columns=col_names)
        st.write(orders_df.to_html(index=False, escape=False), unsafe_allow_html=True)
    else:
        st.write("No orders found for customer ID", customer_id)

# Run the app
if __name__ == '__main__':
    view_orders()
