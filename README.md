# on-cron

A lightweight command-line tool to check if a cron expression is currently due to run.

## Installation

### Quick Install (Linux/macOS)

```bash
curl -fsSL https://github.com/vitalyu/on-cron/releases/latest/download/oncron_$(uname -s | tr '[:upper:]' '[:lower:]')_$(uname -m | sed 's/x86_64/amd64/') -o /usr/local/bin/on-cron && chmod +x /usr/local/bin/on-cron
```

### From Source

```bash
go install github.com/vitalyu/on-cron/cmd/on-cron@latest
```

### Manual Download

Download pre-built binaries from the [releases page](https://github.com/vitalyu/on-cron/releases).

## Usage

```bash
on-cron [options] <cron-expression>
```

### Options

- `-v` - Show version information
- `-q` - Quiet mode (suppress output)

### Exit Codes

- `0` - Cron expression is due to run now
- `1` - Cron expression is not due to run now  
- `2` - Invalid cron expression or error

## Examples

### Basic Usage

Check if a cron job should run every minute:
```bash
on-cron "* * * * *"
echo $?  # 0 if due, 1 if not due
```

Check if a daily job at 9 AM should run:
```bash
on-cron "0 9 * * *"
```

Check if a weekly job (Mondays at 2 PM) should run:
```bash
on-cron "0 14 * * 1"
```

### Shell Scripting

Use in shell scripts to conditionally run commands:

```bash
#!/bin/bash
# Run backup every day at 2 AM
if on-cron "0 2 * * *"; then
    echo "Running daily backup..."
    ./backup.sh
fi
```

```bash
#!/bin/bash
# Run maintenance every Sunday at midnight
on-cron "0 0 * * 0" && {
    echo "Running weekly maintenance..."
    ./maintenance.sh
}
```

### Quiet Mode

Use quiet mode in scripts to suppress output:
```bash
on-cron -q "0 */6 * * *" && echo "Running every 6 hours task"
```

### Complex Expressions

Check if a job should run every 15 minutes during business hours:
```bash
on-cron "*/15 9-17 * * 1-5"
```

Check if a monthly report should run on the first day of each month at 8 AM:
```bash
on-cron "0 8 1 * *"
```

## Cron Expression Format

The tool supports standard 5-field cron expressions:

```
* * * * *
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, Sunday = 0 or 7)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

### Special Characters

- `*` - Any value
- `,` - Value list separator
- `-` - Range of values
- `/` - Step values
- `?` - No specific value (day of month/week only)

### Examples of Valid Expressions

- `0 0 * * *` - Daily at midnight
- `*/5 * * * *` - Every 5 minutes
- `0 9-17 * * 1-5` - Every hour from 9 AM to 5 PM, Monday to Friday
- `0 0 1 */3 *` - First day of every 3rd month at midnight
- `30 2 * * 0` - Every Sunday at 2:30 AM

## Use Cases

- **CI/CD Pipelines**: Check if scheduled jobs should run
- **Monitoring**: Verify cron job timing in scripts
- **Container Orchestration**: Trigger tasks based on cron schedules
- **System Administration**: Validate cron expressions before deployment

## License

This project is open source. See the LICENSE file for details.