Swagger::Docs::Config.register_apis({
  "1.0" => {
    # the extension used for the API
    :api_extension_type => :json,
    # the output location where your .json files are written to
    :api_file_path => "public/swagger_docs",
    # the URL base path to your API
    # if you want to delete all .json files at each generation
    :clean_directory => true,
    :formatting => :pretty
  }
})
