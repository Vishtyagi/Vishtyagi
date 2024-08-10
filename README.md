# ejPlus migration

A sandpit for trying out ideas on rearchitecting ejPlus.

## Building

The solution can be built inside Visual Studio for development purposes.

## Running locally

You can run Lambdas locally provided you have the [Mock Lambda Test Tool installed](https://github.com/aws/aws-lambda-dotnet/tree/master/Tools/LambdaTestTool)

```
dotnet tool install -g Amazon.Lambda.TestTool-8.0
```

For a convenient way to launch this from Visual Studio, go to Tools -> External Tools and add the following:

- Title: Lambda Test Tool
- Command: dotnet.exe
- Arguments: lambda-test-tool-8.0 --port 5050
- Use Output Window: checked

This will add a new Tools menu option "Lambda Test Tool" that can be used to start and stop the test tool.

You can then hit F5 to debug the Lambda function. Since this is packaged as an executable, in the test tool choose the "Executable Assembly" option and enqueue an S3 Put event.

The event will be picked up by your locally debugging function, which you will see reflected in the console logs.

```json
{
  "Timestamp": "2024-02-12T21:04:27:887Z",
  "EventId": 0,
  "LogLevel": "Information",
  "Category": "easyJet.eResConnect.ejPlus.Zuora.Lambda.LambdaHandler",
  "Message": "Received ObjectCreated:Put for HappyFace.jpg from bucket sourcebucket",
  "State": {
    "Message": "Received ObjectCreated:Put for HappyFace.jpg from bucket sourcebucket",
    "EventName": "ObjectCreated:Put",
    "ObjectKey": "HappyFace.jpg",
    "BucketName": "sourcebucket",
    "{OriginalFormat}": "Received {EventName} for {ObjectKey} from bucket {BucketName}"
  },
  "Scopes": ["{ AwsRequestId = 000000000001 }"]
}
```

## Deploying

First create the Lambda package

```powershell
cd src/easyJet.eResConnect.ejPlus.Zuora.Lambda

dotnet publish

Compress-Archive -Path bin/Release/net8.0/linux-arm64/publish/* -DestinationPath bin/Release/easyJet.eResConnect.ejPlus.Zuora.Lambda.zip -Force
```

Next upload to the S3 bucket referenced in the Terraform

```powershell
aws s3 cp bin/Release/easyJet.eResConnect.ejPlus.Zuora.Lambda.zip s3://ej-b2b-dev1-lambda-artifacts/b2b/series-seating/easyJet.eResConnect.ejPlus.Zuora.Lambda.zip
```

If it hasn't been provisioned already, now is the time to use Terraform to create the infrastructure.

```powershell
cd terraform
./tfinit.ps1 -environment b2b-dev1

./tfapply.ps1
```

Finally, update the function code

```powershell
aws lambda update-function-code --function-name SeriesSeatingSplitBooking --s3-bucket ej-b2b-dev1-lambda-artifacts --s3-key b2b/series-seating/easyJet.eResConnect.ejPlus.Zuora.Lambda.zip
```

## Testing

Upload a file to the `touroperator/in` folder of the `ej-b2b-dev1-series-seating` bucket. The Lambda function will be invoked and output will appear in CloudWatch under the `/aws/lambda/SeriesSeatingSplitBooking` log group.
