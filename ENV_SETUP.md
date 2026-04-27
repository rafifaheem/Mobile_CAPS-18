# Environment Configuration Setup

## Quick Start

1. **Install dependencies:**
```bash
flutter pub get
```

2. **Copy environment file:**
```bash
cp .env.example .env
```

3. **Update .env with your configuration:**
```env
API_BASE_URL=http://devom.silog.co.id:8000
API_HOST=devom.silog.co.id
```

4. **Run the app:**
```bash
flutter run
```

## Environment Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|----------|
| `API_BASE_URL` | Full API base URL | ✅ | `http://devom.silog.co.id:8000` | `http://localhost:8000` |
| `API_HOST` | API host only | ✅ | `devom.silog.co.id` | `localhost` |
| `API_PORT` | API port | ✅ | `8000` | `8000` |
| `API_PROTOCOL` | Protocol (http/https) | ✅ | `http` | `https` |
| `API_VERSION` | API version | ❌ | `v1` | `v2` |
| `API_TIMEOUT` | Request timeout (seconds) | ❌ | `2` | `30` |
| `API_FALLBACK_HOST_1` | Fallback server 1 | ❌ | `devom1.silog.co.id` | `backup1.domain.com` |
| `API_FALLBACK_HOST_2` | Fallback server 2 | ❌ | `devom2.silog.co.id` | `backup2.domain.com` |
| `DEBUG_MODE` | Enable debug logging | ❌ | `true` | `false` |
| `LOG_LEVEL` | Logging level | ❌ | `debug` | `info` |
| `ENABLE_ANALYTICS` | Enable analytics | ❌ | `false` | `true` |
| `ENABLE_CRASH_REPORTING` | Enable crash reports | ❌ | `true` | `false` |
| `APP_NAME` | Application name | ❌ | `CargoInd` | `MyApp` |
| `APP_VERSION` | Application version | ❌ | `1.0.0` | `2.1.0` |

## Environment Setup Examples

### 🏠 Local Development
```env
# Local Backend
API_BASE_URL=http://localhost:8000
API_HOST=localhost
API_PORT=8000
API_PROTOCOL=http
DEBUG_MODE=true
LOG_LEVEL=debug
```

### 🧪 Staging Environment
```env
# Staging Server
API_BASE_URL=https://staging-api.domain.com
API_HOST=staging-api.domain.com
API_PORT=443
API_PROTOCOL=https
DEBUG_MODE=true
ENABLE_ANALYTICS=false
```

### 🚀 Production Environment
```env
# Production Server
API_BASE_URL=https://api.domain.com
API_HOST=api.domain.com
API_PORT=443
API_PROTOCOL=https
API_FALLBACK_HOST_1=api-backup1.domain.com
API_FALLBACK_HOST_2=api-backup2.domain.com
DEBUG_MODE=false
LOG_LEVEL=error
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
```

### 🐳 Docker Environment
```env
# Docker Compose
API_BASE_URL=http://backend:8000
API_HOST=backend
API_PORT=8000
API_PROTOCOL=http
DEBUG_MODE=true
```

## Deployment Checklist

### For New Server/Developer:
1. ✅ Copy `.env.example` to `.env`
2. ✅ Update `API_BASE_URL` with correct server URL
3. ✅ Update `API_HOST` with correct hostname
4. ✅ Set `API_PROTOCOL` (http for dev, https for prod)
5. ✅ Configure fallback hosts if available
6. ✅ Set `DEBUG_MODE=false` for production
7. ✅ Enable analytics/crash reporting for production
8. ✅ Run `flutter pub get`
9. ✅ Test connection with `flutter run`

### Required Variables (Must be set):
- `API_BASE_URL` - Backend server URL
- `API_HOST` - Backend hostname
- `API_PORT` - Backend port
- `API_PROTOCOL` - http or https

### Optional Variables (Have defaults):
All other variables have sensible defaults and can be omitted.

## Different Environments

- `.env` - Development (gitignored)
- `.env.example` - Template (committed)
- `.env.staging` - Staging config
- `.env.production` - Production config

## Testing Connection

The app will automatically use environment variables on startup. Check console logs for:
```
🔧 GET http://your-api-url/health
🔧 Response status: 200
```

## Troubleshooting

### Common Issues:
1. **Package not found**: Run `flutter pub get`
2. **Connection failed**: Check `API_BASE_URL` format
3. **CORS errors**: Verify backend CORS settings
4. **SSL errors**: Use `http://` for local development

### Debug Steps:
```bash
# Clean and reinstall
flutter clean
flutter pub get

# Check .env file exists
ls -la .env

# Verify pubspec.yaml has flutter_dotenv
grep flutter_dotenv pubspec.yaml
```

## Security Notes

⚠️ **Important**: 
- Never commit `.env` files to git
- Use HTTPS in production
- Don't put sensitive data in `.env.example`
- Rotate API keys regularly