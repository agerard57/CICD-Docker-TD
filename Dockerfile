# Create temporary image to build the app
FROM mcr.microsoft.com/dotnet/core/sdk:2.1 AS build
WORKDIR /app

# copy source files
COPY *.sln .
COPY humus-mazegenerator/. ./humus-mazegenerator/
COPY HmgAPI/. ./HmgAPI/
COPY mazegeneratorTester/. ./mazegeneratorTester/
COPY ConsoleDebugger/. ./ConsoleDebugger/
COPY version.txt .
# build
RUN dotnet publish HmgAPI/HmgAPI.csproj -c Release /p:Version=$(cat version.txt) -o out
# run tests
RUN dotnet test

# Create runtime image based on previous image
#FROM mcr.microsoft.com/dotnet/core/runtime:2.1

#WORKDIR /app
#COPY --from=build /app/ConsoleDebugger/out .
#ENTRYPOINT ["dotnet", "ConsoleDebugger.dll"]

FROM mcr.microsoft.com/dotnet/core/aspnet:2.1

WORKDIR /app
COPY --from=build /app/HmgAPI/out .
ENTRYPOINT ["dotnet", "HmgAPI.dll"]
