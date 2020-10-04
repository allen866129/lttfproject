# LTTF project

## Installation

- Ubuntu 18.04 LTS (Bionic)

  - Pre-requirement
    - Install dependencies
      ```
      sudo apt update
      sudo apt -y install git gnupg curl
      sudo apt -y install postgresql postgresql-contrib libpq-dev
      ```
    - Install RVM (could refer to their [website](https://rvm.io/rvm/install))
      ```
      gpg --keyserver hkp://pool.sks-keyservers.net:80 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
      \curl -sSL https://get.rvm.io | bash -s stable
      source ~/.rvm/scripts/rvm
      ```
  - Clone project (install git first)
    - `git clone ${this repo}`
  - Recover the necessary yaml files

    - Recovery

      ```
      cp ${proj_root}/config/database.yml.template ${proj_root}/config/database.yml
      cp ${proj_root}/config/myappconfig.yml.template ${proj_root}/config/myappconfig.yml
      ```

    - Please contact other contributer for getting more detailed `myappconfig.yml` after build up the project sucessfully

  - Setup postgreSQL
    - Replace the `${db_name}`, `${db_user_name}`, `${db_passwd}` in `config/database.yml` by your custom value
    - Setup postgreSQL's role by above setting
      ```
      apt-get -y install postgresql postgresql-contrib libpq-dev
      su - postgres
      psql
      create role ${db_user_name} with createdb login password '${db_passwd}';
      \du (check the role is sucessfully created)
      CTRL+D
      exit
      ```
    - Setup ROR database
      ```
      rake db:setup
      rake db:migrate
      ```
  - Setup lttfproject
    ```
    rvm install 2.4.1
    gem install bundler --version 1.16.6
    cd ${proj_root}
    bundle install
    ```

## Run

- `rails s -b 0.0.0.0`
