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
- Implement front-end that lists products
- Refactor only_allowed_roles to a shared module
- Use a changeset to whitelist and check for user input for the buy_products controller

### Assignment details:

# Exercise brief

Design an API for a vending machine, allowing users with a “seller” role to add, update or remove products, while users with a “buyer” role can deposit coins into the machine and make purchases. Your vending machine should only accept 5, 10, 20, 50 and 100 cent coins

**Tasks**

- [x] REST API should be implemented consuming and producing “application/json” [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app_web/router.ex#L17C28-L17C28)
- [x] Implement product model with amountAvailable, cost, productName and sellerId fields [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app/products/product.ex#L7-L15)
- [x] Implement user model with username, password, deposit and role fields [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app/accounts/user.ex)
- [x] Implement an authentication method (basic, oAuth, JWT or something else, the choice is yours) [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app/accounts/user_token.ex)
- [x] All of the endpoints should be authenticated unless stated otherwise [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app_web/router.ex#L16-L51)
- [x] Implement CRUD for users (POST /user should not require authentication to allow new user registration) [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app_web/controllers/api/v1/user_controller.ex)
- [x] Implement CRUD for a product model (GET can be called by anyone, while POST, PUT and DELETE can be called only by the seller user who created the product) [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app_web/router.ex#L35) [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app_web/router.ex#L47) [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app_web/controllers/api/v1/product_controller.ex#L10)
- [x] Implement /deposit endpoint so users with a “buyer” role can deposit only 5, 10, 20, 50 and 100 cent coins into their vending machine account [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app_web/controllers/api/v1/deposit_controller.ex#L9) [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app_web/controllers/api/v1/deposit_controller.ex#L17-L33) [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app/deposits/deposit.ex#L32)
- [x] Implement /buy endpoint (accepts productId, amount of products) so users with a “buyer” role can buy products with the money they’ve deposited. API should return total they’ve spent, products they’ve purchased and their change if there’s any (in an array of 5, 10, 20, 50 and 100 cent coins) [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app_web/controllers/api/v1/buy_product_controller.ex#L11-L56)
- [x] Implement /reset endpoint so users with a “buyer” role can reset their deposit back to 0 [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/lib/app_web/controllers/api/v1/deposit_controller.ex#L46-L61)
- [x] Create web interface for interaction with the API, design choices are left to you [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/tree/main/lib/app_web/live) [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/tree/main/lib/app_web/components)  [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/tree/main/lib/app_web/controllers/page_html)
- [x] Take time to think about possible edge cases and access issues that should be solved [implemented](https://github.com/DanielZwijnenburg/Match_technical_test/blob/main/README.md#improvements)

**Evaluation criteria:**

- Language/Framework of choice best practices
- Edge cases covered
- Write tests for /deposit, /buy and one CRUD endpoint of your choice
- Code readability and optimization

**Bonus:**

- If somebody is already logged in with the same credentials, the user should be given a message "There is already an active session using your account". In this case the user should be able to terminate all the active sessions on their account via an endpoint i.e. /logout/all
- Attention to security
