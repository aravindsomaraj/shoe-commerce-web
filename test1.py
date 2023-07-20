import psycopg2

# Connect to the PostgreSQL database
con = psycopg2.connect(
    database="shoe",
    user="saarang",
    password="qwerty",
    host="localhost",
    port="5432"
)

cur = con.cursor()

result = cur.callproc("change_quantity_inventory",[9, 10] )
result = cur.callproc("change_quantity_inventory",[10, 24] )
result = cur.callproc("change_quantity_inventory",[11, 15] )

status = cur.fetchall()


print(status[0][0])

con.commit()
cur.close()
con.close()