# Webpage
## Setup
To run this project, you will need the following software:
- [flutter](https://flutter.dev/docs/get-started/install)
- [protoc](https://grpc.io/docs/protoc-installation/)

To enable Google Maps support, you will need to add your API key to index.html:
``` 
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
```

When you first clone this repository, you will also need to run the following commands to get setup:

- Enable the protobuf dart plugin:
```
$ flutter pub global activate protoc_plugin
```
- Generate the dart protobuf files:
```
$ protoc --dart_out=lib/proto -I proto proto/*.proto
```