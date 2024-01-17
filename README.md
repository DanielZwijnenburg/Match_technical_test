# VendingMachine

Hi this is the Repo for the technical test for MVP Match.

Clone this repo. Run `mix setup` to install and setup the dependencies
run `mix phx.server` to start the server.

The api is available at `api/v1/`.

You can find the postman collection [here](https://github.com/DanielZwijnenburg/Match_technical_test/tree/main/docs/MVPMatch.postman_collection.json)

Make sure to create a buyer and seller user first. Write down the tokens and use those in the requests to create deposits, products and to buy products.

## Design choices:
- Deposits are stored in the database, this enables 'tracking' or 'counting' of coins
- Product cost must be divideable by 5, 10, 20 or 50. This ensures that the change can always be properly calculated.
- Queries regarding makeing deposits, updating user deposit and buying products are atomic. This ensures data integrity
- Useage of api and web tokens to track sessions and api usage.
- Different api scopes are used for securing the different endpoints
- Plugs are used to allow for users with a certain role to take action
- Getting and/or updating products is scoped to the owning user
- Consuming the API to use on the Front-end is not the Phoenix way.
- I take pride on testing, everything is fully teste, please check it out
- I take pride on clean and readable code, please check it out
- I take pride on commit message, please check it out

Due to time constrains I am not able to get the following improvements done.

### Improvements
- Add & run Credo
- Add & run Sobelow
- Add Types
- Refactor tables to use uuid's so that user_ids can't be guessed. (security)
- buy and reset andpoints are not restfull. Refactor them to producs/:id/buy and user/:id/reset (still not restfull but better
- extract secrets (signing salt, database, etc) to env vars
- Rename user.deposit to something that better represents a balance
- The vending machine needs to have an own internal 'buffer' of change for the different 'allowed coins'. This is to prevent a scenario where a buyer only deposits coins of 50, and the change is less than 50.
- Refactor the deposits table to a transactions table. To store deposits and 'buys'. This can be used to gather some 'analytics' on which coins are used the most. And which products are being sold the most.
- Use api and web tokens to list active sessions
- Implement user show
- Refactor only_allowed_roles to a shared module
- Use a changeset to whitelist and check for user input for the buy_products controller

### Assignment details:

# Exercise brief

Design an API for a vending machine, allowing users with a “seller” role to add, update or remove products, while users with a “buyer” role can deposit coins into the machine and make purchases. Your vending machine should only accept 5, 10, 20, 50 and 100 cent coins

**Tasks**

- REST API should be implemented consuming and producing “application/json”
- Implement product model with amountAvailable, cost, productName and sellerId fields
- Implement user model with username, password, deposit and role fields
- Implement an authentication method (basic, oAuth, JWT or something else, the choice is yours)
- All of the endpoints should be authenticated unless stated otherwise
- Implement CRUD for users (POST /user should not require authentication to allow new user registration)
- Implement CRUD for a product model (GET can be called by anyone, while POST, PUT and DELETE can be called only by the seller user who created the product)
- Implement /deposit endpoint so users with a “buyer” role can deposit only 5, 10, 20, 50 and 100 cent coins into their vending machine account
- Implement /buy endpoint (accepts productId, amount of products) so users with a “buyer” role can buy products with the money they’ve deposited. API should return total they’ve spent, products they’ve purchased and their change if there’s any (in an array of 5, 10, 20, 50 and 100 cent coins)
- Implement /reset endpoint so users with a “buyer” role can reset their deposit back to 0
- Create web interface for interaction with the API, design choices are left to you
- Take time to think about possible edge cases and access issues that should be solved

**Evaluation criteria:**

- Language/Framework of choice best practices
- Edge cases covered
- Write tests for /deposit, /buy and one CRUD endpoint of your choice
- Code readability and optimization

**Bonus:**

- If somebody is already logged in with the same credentials, the user should be given a message "There is already an active session using your account". In this case the user should be able to terminate all the active sessions on their account via an endpoint i.e. /logout/all
- Attention to security
