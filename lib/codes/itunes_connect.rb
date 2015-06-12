require 'fastlane_core/itunes_connect/itunes_connect'

module Codes
	class ItunesConnect < FastlaneCore::ItunesConnect

	 # PROMO_URL = "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wa/LCAppPage/viewPromoCodes?adamId=[[app_id]]&platform=[[platform]]"
	PROMO_URL = "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wa/LCAppPage/viewPromoCodes?adamId=[[app_id]]&versionString=latest&platform=ios"
	CODE_URL = "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/redeemLandingPage?code=[[code]]"

	def run(args)
		number_of_codes = args[:number_of_codes]

		code_or_codes = number_of_codes == 1 ? "code" : "codes"
		Helper.log.info "Downloading #{number_of_codes} promo #{code_or_codes}..."

		p	args

		app_id = args[:apple_id]
		app_id ||= (FastlaneCore::ItunesSearchApi.fetch_by_identifier(args[:app_identifier])['trackId'] rescue nil)
		p  app_id

		app_identifier = args[:app_identifier]
		p  app_identifier

			if app_id.to_i == 0 or app_identifier.to_s.length == 0
				raise "Could not find app using the following information: #{args}. Maybe the app is not in the store. Pass the Apple ID of the app as well!".red
			end

		app = FastlaneCore::ItunesSearchApi.fetch(app_id)
		platform = "ios"

		# Use Pathname because it correctly handles the distinction between relative paths vs. absolute paths
		output_file_path = Pathname.new(args[:output_file_path]) if args[:output_file_path]
		output_file_path ||= Pathname.new(File.join(Dir.getwd, "#{app_identifier || app_id}_codes.txt"))
		raise "Insufficient permissions to write to output file".red if File.exists?(output_file_path) and not File.writable?(output_file_path)
		visit PROMO_URL.gsub("[[app_id]]", app_id.to_s).gsub("[[platform]]", platform)

		begin
			text_fields = wait_for_elements("input[type=text]")
		rescue
			raise "Could not open details page for app #{app_identifier}. Are you sure you are using the correct apple account and have access to this app?".red
		end
			raise "There should only be a single text input field to specify the number of codes".red unless text_fields.count == 1

		text_fields.first.set(number_of_codes.to_s)
		click_next
		Helper.log.debug "Accepting the App Store Volume Custom Code Agreement"
		wait_for_elements("input[type=checkbox]").first.click
		click_next

		# the find(:xpath, "..") gets the parent element of the previous expression
		download_url = wait_for_elements("a > img").first.find(:xpath, '..')['href']

		codes = download_codes download_url

		if args[:urls]
			codes = codes.split("\n").map do |code|
				code +" - "+ CODE_URL.gsub("[[code]]", code)
			end
			codes = codes.join("\n") + "\n"
		end

		bytes_written = File.write(output_file_path.to_s, codes, mode: "a+")
		Helper.log.warn "Could not write your codes to the codes.txt file, but you can still access them from iTunes Connect later" if bytes_written == 0
		Helper.log.info "Added generated codes to '#{output_file_path.to_s}'".green unless	bytes_written == 0

		Helper.log.info "Your codes were successfully downloaded:".green
		puts codes
	end

	def click_next
		wait_for_elements("input.continueActionButton").first.click
	end

	def download_codes(url)
		host = Capybara.current_session.current_host
		url = URI.join(host, url)
		Helper.log.debug "Downloading promo code file from #{url}"

		cookie_string = ""
		page.driver.cookies.each do |key, cookie|
		cookie_string << "#{cookie.name}=#{cookie.value};"
		end

		open(url, "Cookie" => cookie_string).read
	end

	end
end
