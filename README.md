#Cran Packages

## 1. Requirements:
    1.  Ruby 2.7.0
    2.  dotenv gem (manage multiple environments)
    3.  PostgreSQL (min version 10)

## 2. Setting project, follow next steps
  1. `gem install bundler -v 2.1.2` Installs bundler gem
  2. `gem install dotenv` Installs dotenv gem
  3. `bundle install`
  4. Set environment variables, creates .env file with next values:
  ```
      DATABASE_URL=postgres://localhost:5432/cran_packages_dev
      APP_ENV=dev
      DEFAULT_LOCALE=en
  ```
  5. Create database cran_packages_dev
     
     
## 3. Command execution
  Any command line sentence should include `dotenv -f .env`, for instance 
  - Run migrations: `dotenv -f .env rake db:migrate`
  - Run console: `dotenv -f .env rake console`
  - Run app: `dotenv -f .env shotgun`, (default port will be 9393)

## 4. Test environment
  Any command line sentence should include `dotenv -f .env.test`, and you can 
  - Create database cran_packages_test
  - Run test: `dotenv -f .env rspec spec/`
  
