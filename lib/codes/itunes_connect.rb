module Codes
  class ItunesConnect

    def download(args)
      number_of_codes = args[:number_of_codes]

      code_or_codes = number_of_codes == 1 ? 'code' : 'codes'
      UI.message "Downloading #{number_of_codes} promo #{code_or_codes}..."

      fetch_app_data args

      # Use Pathname because it correctly handles the distinction between relative paths vs. absolute paths
      output_file_path = Pathname.new(args[:output_file_path]) if args[:output_file_path]
      output_file_path ||= Pathname.new(File.join(Dir.getwd, "#{@app.apple_id}_codes.txt"))
      User.error('Insufficient permissions to write to output file') if File.exist?(output_file_path) && !File.writable?(output_file_path)

      promocodes = @app.live_version.generate_promocodes!(number_of_codes)

      request_date = Time.at(promocodes.effective_date / 1000)
      codes = promocodes.codes

      format = args[:format]
      if format
        output = download_format(codes, format, request_date, app)
      else
        output = codes.join("\n")
      end

      bytes_written = File.write(output_file_path.to_s, output, mode: 'a+')
      UI.important 'Could not write your codes to the codes.txt file, but you can still access them from iTunes Connect later' if bytes_written == 0
      UI.success "Added generated codes to '#{output_file_path}'" unless  bytes_written == 0

      UI.success "Your codes (requested #{request_date}) were successfully downloaded:"
      puts output
    end

    def download_format(codes, format, request_date, app)
      format = format.gsub(/%([a-z])/, '%{\\1}') # %c => %{c}

      lines = codes.map do |code|
        format % {
          c: code,
          b: app['bundleId'],
          d: request_date, # e.g. 20150520110716 / Cupertino timestamp...
          i: app['trackId'],
          n: "\'#{app['trackName']}\'",
          p: app_platform(app),
          u: CODE_URL.gsub('[[code]]', code)
        }
      end
      lines.join("\n") + "\n"
    end

    def display(args)
      Helper.log.info 'Displaying remaining number of codes promo'

      fetch_app_data args

      # Use Pathname because it correctly handles the distinction between relative paths vs. absolute paths
      output_file_path = Pathname.new(args[:output_file_path]) if args[:output_file_path]
      output_file_path ||= Pathname.new(File.join(Dir.getwd, "#{@app.apple_id}_codes_info.txt"))
      fail 'Insufficient permissions to write to output file'.red if File.exist?(output_file_path) && !File.writable?(output_file_path)

      app_promocodes = @app.promocodes.first

      remaining = app_promocodes.maximum_number_of_codes - app_promocodes.number_of_codes

      bytes_written = File.write(output_file_path.to_s, remaining, mode: 'a+')
      UI.important 'Could not write your codes to the codes_info.txt file, but you can still access them from iTunes Connect later' if bytes_written == 0
      UI.success "Added information of quantity of remaining codes to '#{output_file_path}'" unless bytes_written == 0

      puts remaining
    end

    private

    def fetch_app_data(args)
      Spaceship::Tunes.login(args[:username])
      @app = Spaceship::Tunes::Application.find(args[:apple_id] || args[:app_identifier] )
    end
  end
end
