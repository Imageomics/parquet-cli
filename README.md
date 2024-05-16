# parquet-cli
Parquet files have many advantages over text-based formats like CSV except for one: they are not human-readable.

This image provides the utility of the [parquet-cli](https://github.com/apache/parquet-mr/tree/master/parquet-cli) command line tool to help fill this gap.

## Usage
Please refer to the [parquet-cli documentation](https://github.com/apache/parquet-mr/tree/master/parquet-cli#help) for available commands and flags.

## Retrieval
First, pull the image from GHCR:

```bash
apptainer pull oras://ghcr.io/imageomics/parquet-cli:latest
```

Move the image to your preferred location:

```bash
mv parquet-cli_latest.sif /preferred/path/parquet-cli_latest.sif
```

## Running the Image
Run the container to inspect your Parquet file:

```bash
apptainer run /preferred/path/parquet-cli_latest.sif <flags-and-commands> /path/to/file.parquet
```

For simpler usage, you can add an alias in your `~/.bashrc` file:

```bash
alias parquet='apptainer --silent run --cleanenv /preferred/path/parquet-cli_latest.sif'
```

Then you can use the `parquet` command to inspect Parquet files:

```bash
parquet <flags-and-commands> /path/to/file.parquet
```

## Building the Image
To build the image from the definition file, run the following command:

```bash
apptainer build <my-image>.sif parquet-cli.def
```