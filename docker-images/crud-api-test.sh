#!/bin/bash
set -x

# Health check
curl -X GET http://localhost:8080/healthz

# Metrics
curl -X GET http://localhost:9100/metrics

# Create item with name=FooBar
curl -X POST -H "Content-Type: application/json" -d '{"name":"FooBar"}' http://localhost:8080/api/items

# Try to create item with invalid name
curl -X POST -H "Content-Type: application/json" -d '{"name":"Fooooooooooooooooooooooooooooooooo"}' http://localhost:8080/api/items

# Fetch items with name=FooBar
curl -X GET http://localhost:8080/api/items/%5EFooBar%24

# Fetch all items
curl -X GET http://localhost:8080/api/items/%5E.*%24

# Update items with name = FooBar -> BarFoo
curl -X PUT -H "Content-Type: application/json" -d '{"name":"BarFoo"}' http://localhost:8080/api/items/%5EFooBar%24

# Try to update items with name = FooBar to an invalid name
curl -X PUT -H "Content-Type: application/json" -d '{"name":"Fooooooooooooooooooooooooooooooooo"}' http://localhost:8080/api/items/%5EFooBar%24

# Delete items with name=FooBar
curl -X DELETE http://localhost:8080/api/items/%5EFooBar%24

# Delete all items
curl -X DELETE http://localhost:8080/api/items/%5E.*%24
