<?php

include '../vendor/autoload.php';
$foo = new App\Foo();

?><!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Welcome to Docker NGINX PHP MySQL</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4a6cf7;
            --secondary-color: #6941c6;
            --accent-color: #0ea5e9;
            --background-color: #f9fafb;
            --text-color: #1f2937;
            --light-text-color: #6b7280;
            --border-color: #e5e7eb;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --error-color: #ef4444;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            background-color: var(--background-color);
            color: var(--text-color);
            line-height: 1.6;
            padding: 0;
            margin: 0;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
            flex: 1;
        }

        header {
            background: linear-gradient(to right, var(--primary-color), var(--secondary-color));
            color: white;
            padding: 2rem 0;
            text-align: center;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }

        header h1 {
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
        }

        header p {
            font-size: 1.25rem;
            opacity: 0.9;
        }

        main {
            padding: 2rem 0;
        }

        .card {
            background-color: white;
            border-radius: 0.5rem;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
            overflow: hidden;
            margin-bottom: 2rem;
        }

        .card-header {
            padding: 1.5rem;
            border-bottom: 1px solid var(--border-color);
        }

        .card-header h2 {
            font-size: 1.5rem;
            color: var(--primary-color);
            margin: 0;
        }

        .card-body {
            padding: 1.5rem;
        }

        .card-body p {
            margin-bottom: 1rem;
        }

        .card-body ul {
            list-style-type: none;
            margin-bottom: 1rem;
        }

        .card-body ul li {
            margin-bottom: 0.5rem;
            padding-left: 1.5rem;
            position: relative;
        }

        .card-body ul li:before {
            content: "→";
            color: var(--accent-color);
            position: absolute;
            left: 0;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 2rem;
        }

        .feature-card {
            background-color: white;
            border-radius: 0.5rem;
            padding: 1.5rem;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        .feature-card h3 {
            color: var(--primary-color);
            margin-bottom: 0.75rem;
            font-size: 1.25rem;
        }

        .feature-card p {
            color: var(--light-text-color);
            font-size: 0.95rem;
        }

        .status {
            background-color: var(--success-color);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 600;
            display: inline-block;
            margin-left: 0.5rem;
        }

        code {
            font-family: Consolas, Monaco, 'Andale Mono', 'Ubuntu Mono', monospace;
            background-color: #f1f5f9;
            padding: 0.2em 0.4em;
            border-radius: 0.25rem;
            font-size: 0.875em;
        }

        footer {
            background-color: white;
            border-top: 1px solid var(--border-color);
            padding: 1.5rem 0;
            text-align: center;
            color: var(--light-text-color);
            font-size: 0.875rem;
        }

        .badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            background-color: var(--accent-color);
            color: white;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-right: 0.5rem;
            margin-bottom: 0.5rem;
        }

        @media (max-width: 768px) {
            .grid {
                grid-template-columns: 1fr;
            }
            
            header h1 {
                font-size: 2rem;
            }
            
            .container {
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
    <header>
        <h1>Docker NGINX PHP MySQL</h1>
        <p>Your modern PHP development environment</p>
        <span class="status">Ready</span>
    </header>

    <div class="container">
        <main>
            <div class="card">
                <div class="card-header">
                    <h2>Welcome to Your Docker Environment</h2>
                </div>
                <div class="card-body">
                    <p>Congratulations! If you're seeing this page, your PHP environment is running successfully.</p>
                    <p>This environment includes:</p>
                    <ul>
                        <li>NGINX web server</li>
                        <li>PHP <?php echo phpversion(); ?></li>
                        <li>MySQL database</li>
                        <li>PHPMyAdmin (in development environment)</li>
                    </ul>
                    <p>Current PHP class test: <code><?php echo $foo->getName(); ?></code></p>
                </div>
            </div>

            <h2 style="margin-bottom: 1.5rem">Key Features</h2>
            <div class="grid">
                <div class="feature-card">
                    <h3>Development & Production</h3>
                    <p>Easily switch between development and production environments with optimized configurations.</p>
                    <div style="margin-top: 0.75rem">
                        <span class="badge">make dev</span>
                        <span class="badge">make prod</span>
                    </div>
                </div>
                
                <div class="feature-card">
                    <h3>Framework Support</h3>
                    <p>Ready-to-use support for popular PHP frameworks including Symfony and Laravel.</p>
                    <div style="margin-top: 0.75rem">
                        <span class="badge">Symfony</span>
                        <span class="badge">Laravel</span>
                    </div>
                </div>
                
                <div class="feature-card">
                    <h3>Debugging Tools</h3>
                    <p>Integrated with Xdebug and development tools to make debugging efficient and painless.</p>
                </div>
                
                <div class="feature-card">
                    <h3>Security Features</h3>
                    <p>Network separation with frontend and backend layers for enhanced security.</p>
                </div>
            </div>
        </main>
    </div>

    <footer>
        <div class="container">
            <p>Docker NGINX PHP MySQL Environment &copy; <?php echo date('Y'); ?></p>
        </div>
    </footer>
</body>
</html>