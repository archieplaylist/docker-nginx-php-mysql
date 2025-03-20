# Docker Nginx PHP MySQL

[![GitHub version](https://badge.fury.io/gh/nanoninja%2Fdocker-nginx-php-mysql.svg)](https://badge.fury.io/gh/nanoninja%2Fdocker-nginx-php-mysql)
[![GitHub Actions](https://github.com/nanoninja/docker-nginx-php-mysql/workflows/CI/badge.svg)](https://github.com/nanoninja/docker-nginx-php-mysql/actions)

A complete and modern Docker development environment for PHP applications with Nginx, PHP-FPM, MySQL and PHPMyAdmin.

## 🚀 Features

- Easy switch between PHP versions (8.2, 8.3, etc.)
- Environment configurations for development and production
- Support for multiple PHP frameworks (Symfony, Laravel, etc.)
- Two network layers (frontend and backend) for better security
- Integrated Composer for dependency management
- Xdebug for debugging (in development environment)
- Health checks for all services
- Comprehensive Makefile with helpful commands
- PHPMyAdmin for database management (in development environment)

## 📋 Requirements

- Docker Engine (20.10+)
- Docker Compose (2.0+)
- Make (optional, but recommended)

## 🛠️ Installation

### Clone the repository

```bash
git clone https://github.com/nanoninja/docker-nginx-php-mysql.git
cd docker-nginx-php-mysql
```

### Initialize the project

This command will set up everything you need to start development:

```bash
make init
```

## 🏁 Quick Start

### Start the environment

```bash
# Start with default environment (development)
make start

# Or explicitly select an environment
make dev   # For development
make prod  # For production
```

### Access your application

- Web: [http://localhost:8000](http://localhost:8000)
- Secure Web: [https://localhost:3000](https://localhost:3000) (SSL certificates must be configured)
- PHPMyAdmin: [http://localhost:8080](http://localhost:8080) (username: dev, password: dev)

### Stop the environment

```bash
make stop
```

## 🔄 Environment Management

This project supports both development and production environments. Each environment has its own configuration optimized for its specific use case.

### Development Environment

The development environment includes:
- Xdebug for debugging
- PHPMyAdmin for database management
- Development-oriented PHP settings
- Detailed error reporting

To activate:

```bash
make dev
```

### Production Environment

The production environment is optimized for performance and security:
- Disabled development tools
- Optimized PHP settings
- Minimized error reporting
- Enhanced security configurations

To activate:

```bash
make prod
```

### Customizing Environments

You can customize the environments by editing:
- `.env.dev` for development settings
- `.env.prod` for production settings

Common configuration options:

| Variable           | Description                        | Default (Dev)    | Default (Prod)   |
|--------------------|------------------------------------|------------------|------------------|
| PHP_VERSION        | PHP version to use                 | 8.2              | 8.2              |
| PHP_TARGET         | PHP image target                   | dev              | base             |
| MYSQL_VERSION      | MySQL version                      | 8.0              | 8.0              |
| PHP_DISPLAY_ERRORS | Show PHP errors                    | 1                | 0                |
| PHP_MEMORY_LIMIT   | PHP memory limit                   | 256M             | 128M             |
| XDEBUG_ENABLED     | Enable Xdebug                      | 1                | 0                |
| SSL_COUNTRY       | Country code for SSL certificate   | US               | US               |
| SSL_STATE         | State for SSL certificate          | State            | State            |
| SSL_LOCALITY      | City for SSL certificate           | City             | City             |
| SSL_ORGANIZATION  | Organization name for certificate  | Organization     | Organization     |
| SSL_UNIT          | Organizational unit               | IT               | IT               |
| SSL_EMAIL         | Contact email for certificate      | admin@example.com| admin@example.com|
| SSL_DAYS          | Certificate validity in days       | 365              | 365              |
| SSL_KEY_SIZE      | RSA key size in bits              | 4096             | 4096             |

## 🔍 Debugging with Xdebug

Xdebug is automatically configured in the development environment. The setup uses Docker's internal networking to detect the correct host address.

### IDE Configuration

#### For PHPStorm:

1. Go to Settings → PHP → Debug
2. Ensure Xdebug is selected with port 9003
3. Go to Settings → PHP → Servers
4. Add a server:
   - Name: docker
   - Host: localhost
   - Port: 8000
   - Path mapping: Map your project directory to `/var/www/html`

#### For VS Code:

1. Install the PHP Debug extension
2. Create a `.vscode/launch.json` file:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/html": "${workspaceFolder}"
            }
        }
    ]
}
```

### Customizing Xdebug

If you need to customize Xdebug settings, edit the `etc/php/php.ini` file and restart the containers:

```bash
make restart
```

## ⚙️ Project Structure

```
.
├── docker/                # Docker configuration
│   └── php/               # PHP Dockerfile and configuration
├── etc/                   # Configuration files
│   ├── nginx/             # Nginx configuration
│   ├── php/               # PHP configuration
│   └── ssl/               # SSL certificates
├── web/                   # Web root directory
│   ├── app/               # Application code
│   │   ├── src/           # Source code
│   │   └── test/          # Test code
│   └── public/            # Public files
├── data/                  # Data storage
│   └── db/                # Database data
├── .env.dev               # Development environment variables
├── .env.prod              # Production environment variables
├── docker-compose.yml     # Docker Compose configuration
└── Makefile               # Make commands
```

## 🔐 SSL Configuration

To enable HTTPS, generate SSL certificates and update the Nginx configuration:

```bash
# Generate self-signed certificates
make gen-certs

# Edit the Nginx template
# Uncomment the SSL server block in etc/nginx/default.template.conf

# Restart the environment
make restart
```

## 🛠️ Available Commands

The Makefile provides many helpful commands:

### Environment Management

| Command   | Description                                   |
|-----------|-----------------------------------------------|
| init      | Initialize the project                        |
| dev       | Set up development environment                |
| prod      | Set up production environment                 |
| start     | Start all services                            |
| stop      | Stop all services                             |
| restart   | Restart all services                          |
| status    | Show service status                           |
| logs      | View and follow logs                          |
| clean     | Clean project data (reset to initial state)   |

### Development Tools

| Command           | Description                                  |
|-------------------|----------------------------------------------|
| composer-install  | Install PHP dependencies                     |
| composer-update   | Update PHP dependencies                      |
| composer-autoload | Update the autoloader                        |
| test              | Run tests                                    |
| code-sniff        | Check code style with PHP_CodeSniffer        |
| phpmd             | Analyze code with PHP Mess Detector          |
| gen-certs         | Generate SSL certificates                    |
| apidoc            | Generate API documentation                   |

### Database Management

| Command       | Description                           |
|---------------|---------------------------------------|
| db-dump       | Backup all databases                  |
| db-restore    | Restore database from backup          |
| db-connect    | Connect to MySQL shell                |

### Framework Installation

| Command           | Description                   |
|-------------------|-------------------------------|
| install-symfony   | Install Symfony framework     |
| install-laravel   | Install Laravel framework     |

Run `make help` to see all available commands.

## 📊 Database Connection

### Connecting from PHP

```php
<?php
try {
    $dsn = 'mysql:host=mysql;dbname=test;charset=utf8mb4;port=3306';
    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ];
    $pdo = new PDO($dsn, 'dev', 'dev', $options);
} catch (PDOException $e) {
    throw new PDOException($e->getMessage(), (int)$e->getCode());
}
```

### Using PHPMyAdmin

PHPMyAdmin is available at [http://localhost:8080](http://localhost:8080) in the development environment.

Default credentials:
- Server: mysql
- Username: dev
- Password: dev

## 🔧 Advanced Configuration

### Customizing PHP

To customize PHP settings, edit the `etc/php/php.ini` file.

### Customizing Nginx

The Nginx configuration uses a template system with environment variables. Edit `etc/nginx/default.template.conf` to customize the server configuration.

### Customizing MySQL

MySQL configuration can be adjusted through environment variables in the `.env` files.

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.