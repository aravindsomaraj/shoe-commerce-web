### Views
- one view to get all the details for shoe listing.
- to view all available brands 
- to view all shoe_types

### functions
- [done] given the customer id, fetch all the items in their cart                      
- [done] function to add new user and seller                                           
- [done] function to fetch user password and check if a user exist and seller          
- [done] function to add/increase quantity to cart a new product 
- [done] function to add new/increase product count by seller
- [] remove from cart and inventory
- [] get all the details of a shoe for shoe specific listing, given the shoe_id
- [done] a function to enter review

### triggers
<!-- - automatically order some set of shoes when quantity goes below some value. -->
- automatically change the status when quantity reaches 0
- automatically change the rating when a new review is added

### indices     
- [done] name of shoe, brand for searchin, GIN
- [done] price - btree
- [done] type and brand - hash
- [done] seller inventory needs filtering with seller_id - hash

### roles
- [done] admin
- [done] customer
- [done] seller

### Front end
- [] Cart page 
- [] Seller login 
- [] 
- [] 