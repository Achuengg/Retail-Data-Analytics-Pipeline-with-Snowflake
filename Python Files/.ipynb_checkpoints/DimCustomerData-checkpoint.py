# Generate Customer data
# libraries 
import pandas as pd
import csv
import random 
from faker import Faker

# Initialize 

#instace for the class
fake=Faker()

# input the number of rows that the csv file should have 

num_rows=int(input(" Enter the number of rows the csv file should have : "))


# input the name of the csv file (e.g data.csv)

csv_file = input ( " enter the name of the csv file like data.csv : ")

#create the header 
header = ['First Name','Last Name','Gender','DateOfBirth', 'Email', 'Address', 'City', 'State', 'Postal Code', 'Country','LoyaltyProgramID']
type(header)

#open the csv file & write header
with open(csv_file,mode='w',newline='') as file:
    writer=csv.writer(file)
    writer.writerow(header)

# Generate a Single row 
row=[
            fake.first_name()[:50],
            fake.last_name()[:50],
            random.choice(['M','F','Others']),
            fake.date(),
            fake.email(),
            fake.phone_number(),
            fake.address().replace(","," ").replace("\n"," "),
            fake.city()[:50],
            fake.state()[:50],
            fake.postcode(),
            fake.country()[:50],
            random.randint(1,5)
        ]
print(row)

# write the row to the csv file 

#loop and generate multiple rows 
with open(csv_file,mode='a',newline='') as file:
    writer=csv.writer(file)
    for _ in range(num_rows):
        row=[
            fake.first_name()[:50],
            fake.last_name()[:50],
            random.choice(['M','F','Others']),
            fake.date(),
            fake.email(),
            fake.address().replace(","," ").replace("\n"," "),
            fake.city()[:50],
            fake.state()[:50],
            fake.postcode(),
            fake.country()[:50],
            random.randint(1,5)
        ]

        writer.writerow(row)

# print success statement 
print("Done!")

df = pd.read_csv("C:/Users/aksha/Documents/SQL/EndtoEndSalesProject-master/retail_data/DimCustomer/DimCustomerdata.csv")
df.info()

df.head()


