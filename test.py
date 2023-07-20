import psycopg2

# Connect to the PostgreSQL database
conn = psycopg2.connect(
    database="shoe",
    user="buu",
    password="chessiscool",
    host="localhost",
    port="5432"
)

cur = conn.cursor()
cur.execute(" SELECT * FROM check_seller_login('sales@sportsunlimited.com',  'sporunli' )")
status = cur.fetchall()

if(status[0][0] == 'invalid username'):
    print('username doesn\'t exist')
elif(status[0][0] == 'invalid password'):
    print("username or password doesn't match")
elif(status[0][0] == 'accept'):
    print("accept", "seller_id = ",status[0][1])
else:
    print('this should not happen')