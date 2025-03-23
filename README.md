# Docker Nginx PHP MySQL

[![GitHub version](https://badge.fury.io/gh/nanoninja%2Fdocker-nginx-php-mysql.svg)](https://badge.fury.io/gh/nanoninja%2Fdocker-nginx-php-mysql)
[![GitHub Actions](https://github.com/nanoninja/docker-nginx-php-mysql/workflows/CI/badge.svg)](https://github.com/nanoninja/docker-nginx-php-mysql/actions)

A complete and modern Docker development environment for PHP applications with Nginx, PHP-FPM, Composer, MySQL and PHPMyAdmin.

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

### Command Line Reference

For users who don't have access to the `make` utility, a complete reference of all available commands with their manual alternatives is provided in the [Command Line Reference](docs/commands.md) document.

## 🛠️ Installation

### Clone the repository

```bash
git clone https://github.com/nanoninja/docker-nginx-php-mysql.git
cd docker-nginx-php-mysql
```

## 🏁 Getting Started

Setting up your development environment involves just a few simple steps:

### 1. Start the Docker environment

First, start all the Docker containers required for the environment:

```bash
# Start with default environment (development)
make start

# Or explicitly select an environment before starting
make dev   # For development mode
make prod  # For production mode
```

### 2. Initialize the project

After the containers are running, initialize the project to install dependencies and set up the environment:

```bash
make init
```

This command will:

- Copy the composer configuration template
- Install PHP dependencies via Composer
- Set up the appropriate file permissions
- Prepare the environment for development

### 3. Access your application

Once the environment is running and initialized, you can access:

- Web: [http://localhost:8000](http://localhost:8000)
- Secure Web: [https://localhost:3000](https://localhost:3000) (SSL certificates must be configured)
- PHPMyAdmin: [http://localhost:8080](http://localhost:8080) (username: dev, password: dev)

### 4. Stop the environment when finished

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

| Variable               | Description                           | Default (Dev)        | Default (Prod)       |
|------------------------|---------------------------------------|----------------------|----------------------|
| PHP_VERSION            | PHP version to use                    | 8.3                  | 8.3                  |
| PHP_TARGET             | PHP image target                      | dev                  | base                 |
| MYSQL_VERSION          | MySQL version                         | 9.2                  | 9.2                  |
| PHP_DISPLAY_ERRORS     | Show PHP errors                       | 1                    | 0                    |
| PHP_MEMORY_LIMIT       | PHP memory limit                      | 256M                 | 128M                 |
| XDEBUG_ENABLED         | Enable Xdebug                         | 1                    | 0                    |
| APP_WORKSPACE          | Workspace type                        | default              | default              |
| APP_DIR                | Application directory                 | app                  | app                  |
| APP_PUBLIC_DIR         | Public directory (auto-generated)     | app/public           | app/public           |
| PROJECT_NAME           | Project name for Docker volumes       | docker_nginx_php_mysql | docker_nginx_php_mysql |
| MAILHOG_SMTP_PORT      | MailHog SMTP port                     | 1025                 | -                    |
| MAILHOG_UI_PORT        | MailHog web interface port            | 8025                 | -                    |
| MAILHOG_STORAGE        | MailHog storage mode                  | memory               | -                    |

## 🔍 Debugging with Xdebug

This environment comes with Xdebug pre-configured in the development setup, allowing you to debug your PHP applications effectively. This section provides detailed instructions on how to configure and use Xdebug with popular IDEs.

### How Xdebug Works in This Environment

In the development environment (`make dev`), Xdebug is automatically enabled in the PHP container. The configuration includes:

- Xdebug mode set to `develop,debug`
- Automatic connection to your host machine
- Start with request enabled
- Debug port set to 9003 (Xdebug 3 default)

### Configuration for Visual Studio Code

VS Code requires the PHP Debug extension to work with Xdebug. Here's how to set it up:

1. **Install the PHP Debug extension**
   - Open VS Code
   - Go to Extensions (Ctrl+Shift+X or Cmd+Shift+X)
   - Search for "PHP Debug" by Felix Becker
   - Click Install

2. **Create a launch configuration**
   - Create a `.vscode` directory in your project root
   - Create a file named `launch.json` inside the `.vscode` directory
   - Add the following configuration:

```json
{
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/html": "${workspaceFolder}/web"
            },
            "log": true,
            "xdebugSettings": {
                "max_data": 65535,
                "show_hidden": 1,
                "max_children": 100,
                "max_depth": 5
            }
        }
    ]
}
```

When using Xdebug with Docker and VSCode, it's crucial to correctly configure the path mapping between your local filesystem and the Docker container's filesystem.

In our configuration, the local directory `./web` is mounted to the path `/var/www/html` in the container. This distinction is essential for understanding how to configure VSCode.

Your `launch.json` file in VSCode should contain the following mapping:

```json
"pathMappings": {
    "/var/www/html": "${workspaceFolder}/web"
}
```

3. **Start debugging**
   - Set breakpoints in your code by clicking in the gutter next to line numbers
   - Start the debugging session in VS Code (F5 or click the green play button in the Debug panel)
   - Access your application in the browser
   - VS Code should stop at your breakpoints

### Configuration for PHPStorm

PHPStorm has built-in support for Xdebug. Here's how to configure it:

1. **Configure the PHP interpreter**
   - Go to Settings/Preferences → PHP
   - Add a new CLI Interpreter → From Docker
   - Select the PHP container from your docker-compose configuration
   - PHPStorm should detect Xdebug automatically

2. **Set up the server configuration**
   - Go to Settings/Preferences → PHP → Servers
   - Add a new server:
     - Name: docker
     - Host: localhost
     - Port: 8000
     - Check "Use path mappings"
     - Map your project root to `/var/www/html`

3. **Configure Xdebug**
   - Go to Settings/Preferences → PHP → Debug
   - Ensure Xdebug is set to port 9003
   - Enable "Can accept external connections"

4. **Start debugging**
   - Set breakpoints in your code
   - Click on the "Start Listening for PHP Debug Connections" button (telephone icon)
   - Access your application in the browser
   - PHPStorm should stop at your breakpoints

### Troubleshooting Xdebug

If you're having issues with Xdebug, try these common solutions:

1. **Verify Xdebug is enabled**
   ```bash
   docker-compose exec php php -m | grep xdebug
   ```
   This should return "xdebug" if it's enabled.

2. **Check Xdebug settings**
   ```bash
   docker-compose exec php php -i | grep xdebug
   ```
   Review the settings to ensure they match what you expect.

3. **Ensure correct network settings**
   If your host IP address is different or you're using a VPN, you might need to adjust the Xdebug client host in `etc/php/php.ini`:
   ```ini
   xdebug.client_host=host.docker.internal
   ```
   
   On Linux, you might need to use your actual host IP or add `extra_hosts` to your docker-compose.yml:
   ```yaml
   services:
     php:
       extra_hosts:
         - "host.docker.internal:host-gateway"
   ```

4. **Browser extensions**
   Install browser extensions to easily toggle Xdebug sessions:
   - For Chrome: "Xdebug Helper"
   - For Firefox: "Xdebug Helper" or "Xdebug Extension"

### Customizing Xdebug Settings

You can customize Xdebug by editing the `etc/php/php.ini` file. Here are some useful settings you might want to adjust:

```ini
; Adjust max nesting level if you have deeply nested function calls
xdebug.max_nesting_level=1000

; Increase var display max depth for complex objects
xdebug.var_display_max_depth=10

; Increase var display max children
xdebug.var_display_max_children=256

; Increase var display max data
xdebug.var_display_max_data=1024
```

After changing any settings, restart the containers:

```bash
make restart
```

With this setup, you'll have a powerful debugging environment that helps you identify and fix issues in your PHP applications efficiently.

## ⚙️ Project Structure

```
.
├── docker/                # Docker configuration
│   ├── php/               # PHP Dockerfile
│   ├── ssl/               # SSL certificate generator
│   └── mysql/             # MySQL initialization scripts
├── etc/                   # Configuration files
│   ├── nginx/             # Nginx configuration
│   │   └── workspace/     # Workspace-specific configs
│   ├── php/               # PHP configuration
│   └── ssl/               # SSL certificates
├── web/                   # Web root directory
│   └── app/               # Default application code
│       ├── public/        # Public files
│       ├── src/           # Source files
│       └── tests/         # Test code
├── docs/                  # Documentation
│   ├── api/               # API documentation (generated)
│   └── *.md               # Markdown documentation files
├── data/                  # Persistent data
│   └── db/                # Database files
│       └── dumps/         # Database dumps
├── .env.dev               # Development environment variables
├── .env.prod              # Production environment variables
├── docker-compose.yml     # Docker Compose configuration
└── Makefile               # Make commands
```

## 🔐 SSL Configuration

To enable HTTPS, follow these steps:

```bash
# Generate self-signed certificates
make gen-certs

# Enable SSL in Nginx configuration
make enable-ssl

# Restart the environment
make restart
```

You can then access your site via HTTPS at [https://localhost:3000](https://localhost:3000).

The SSL certificates are customizable through environment variables:

| Variable           | Description                        | Default          |
|--------------------|------------------------------------|------------------|
| NGINX_SSL_COUNTRY  | Country code                       | US               |
| NGINX_SSL_STATE    | State/Province                     | State            |
| NGINX_SSL_LOCALITY | City                               | City             |
| NGINX_SSL_ORGANIZATION | Organization name              | Organization     |
| NGINX_SSL_UNIT     | Organizational unit                | IT               |
| NGINX_SSL_EMAIL    | Contact email                      | admin@example.com|
| NGINX_SSL_DAYS     | Certificate validity in days       | 365              |
| NGINX_SSL_KEY_SIZE | RSA key size in bits               | 4096             |

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
| clean-all | Clean all data including volumes              |

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
| enable-ssl        | Enable SSL in Nginx configuration            |
| apidoc            | Generate API documentation                   |

### Database Management

| Command          | Description                           |
|------------------|---------------------------------------|
| db-dump          | Backup all databases                  |
| db-restore       | Restore database from backup          |
| db-connect       | Connect to MySQL shell                |

### Framework Installation

| Command           | Description                   |
|-------------------|-------------------------------|
| install-symfony   | Install Symfony framework     |
| install-laravel   | Install Laravel framework     |

Run `make help` to see all available commands.

## PHP Frameworks Support

This environment supports popular PHP frameworks out of the box. For the best experience with frameworks, follow these recommendations:

### Recommended Workflow

1. **First decide** whether you'll use a framework or the default application
2. **Configure your environment** (development or production)
3. **Install your framework** if needed
4. **Modify your .env file** to point to your framework

### Installing Symfony

```bash
# First, configure your environment
make dev  # or make prod

# Then, install Symfony
make install-symfony

# Finally, modify your .env file to use Symfony
# APP_WORKSPACE=symfony
# APP_PUBLIC_DIR=symfony-app/public

# Restart the containers
make restart
```

### Installing Laravel

```bash
# Follow the same approach
make dev  # or make prod
make install-laravel

# Modify your .env file
# APP_WORKSPACE=laravel
# APP_PUBLIC_DIR=laravel-app/public

make restart
```

### Adding Support for Other Frameworks

If you want to use a framework that's not included in the predefined list, you can add support for it by following these steps:

1. **Create a workspace configuration file** for Nginx:

```bash
# Create a new configuration file in the workspace directory
touch etc/nginx/workspace/yourworkspace.conf
```

2. **Add the specific Nginx rules** for your workspace. For example:

```nginx
# CakePHP configuration example
location / {
    try_files $uri $uri/ /index.php?$args;
}

# Deny access to sensitive directories
location ~ ^/(config|tmp|logs) {
    deny all;
    return 404;
}
```

3. **Install your framework** using Composer:

```bash
docker-compose exec php bash -c "cd /var/www/html && composer create-project your/framework yourworkspace-app"
```

4. **Update your `.env` file** to use the new workspace:

```
APP_WORKSPACE=yourworkspace
APP_PUBLIC_DIR=yourworkspace-app/public
```

5. **Restart the containers** to apply the changes:

```bash
make restart
```

By following these steps, you can extend the environment to support virtually any PHP workspace or custom application structure.

### Important Note

If you switch between environments using `make dev` or `make prod`, you'll need to reconfigure your workspace-specific variables in your `.env` file, as these commands replace the entire file.

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

### Database Initialization

You can add SQL scripts to `docker/mysql/init/` directory. These scripts will be executed automatically when the MySQL container is first started.

### Customizing PHP

To customize PHP settings, edit the `etc/php/php.ini` file.

### Customizing Nginx

The Nginx configuration uses a template system with environment variables. Edit `etc/nginx/default.template.conf` to customize the server configuration.

Framework-specific configurations are stored in `etc/nginx/workspace/` directory.

### Network Architecture

This project uses a two-layer network architecture:

1. **Frontend Network**: For services that need to be accessible from outside (Nginx, PHPMyAdmin)
2. **Backend Network**: For services that should only communicate internally (PHP, MySQL)

This design improves security by isolating internal services from direct external access.

## 📝 License

This project is licensed under the BSD 3-Clause License.

It allows you to:
- Use the software commercially
- Modify the software
- Distribute the software
- Place warranty on the software
- Use the software privately

The only requirements are:
- Include the copyright notice
- Include the license text
- Not use the author's name to promote derived products without permission

For more details, see the LICENSE file in the project repository.