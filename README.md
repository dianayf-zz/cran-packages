#Cran Packages
  Cran packages is a ruby application which collect R packages using the CRAN server, a relational database was used to represent 3 main entities: Cran_packages, Dependencies and Contributors (includes authors and maintainers).

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
  
## 5. API endpoint
  1. List available packages:
    - GET /v1/cran_packages

   - Signature Response:

  ```json
    {
      "data": {
        "name": "A3",
        "version": "1.0.0",
        "title": "Accurate, Adaptable, and Accessible Error Metrics for Predictive Models",
        "license": "GPL (>= 2)",
        "r_version_needed": "R (>= 2.15.0)",
        "publication_date": "2015-08-16 23:05:52",
        "dependencies": [],
        "authors": [
            {
                "name": "Scott Fortmann-Roe",
                "role": "AUTHOR"
            }
        ],
        "maintainers": [
            {
                "name": "Scott Fortmann-Roe",
                "role": "MAINTAINER"
            }
        ]
      }
    }
  ```

## 6. Scheduled task
  - Every day at "00:05" packages' update task was scheduled to run, the main operation just take a sample of 11 packages
  - Run scheduler: `dotenv -f .env bundle exec ruby config/schedule.rb`

## 7. Comments
  - Role types and required dependencies were extracted from https://r-pkgs.org/description.html definitions, the 'Imports' key was used to extract these dependencies.

## 8. Questions:
  - What packages need import the package "htmltools"?
    Based on the comments section and keeping in mind sample package size (11), none of the Packages needs import 'htmltools'  dependency just `aceEditor` but it's out of sample.
  - What is the list of emails of authors or maintainers?
    Email list could be getting with netx query `Contributor.map(&:email).uniq` inside project connsole.
  - Who is the person that has contributed on more packages?
    The highest contributor could be getting with next query `CranPackagesContributor.group_and_count(:contributor_id).order(Sequel.desc(:count)).first.contributor.name` inside project connsole.
