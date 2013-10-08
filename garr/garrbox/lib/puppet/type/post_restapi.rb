# This Resource Type executes a POST to a REST API.
# To verify if the POST has to be done this type checks the values of some filed of the equivalent GET call to the same URL.
#
# Example:
#
# post_restapi { 'test-postapi':
#     url               => 'http://serverurl.edu/api/service',
#     body              => '{ "field" : "newvalue" }',
#     user              => 'basicuser',
#     password          => 'password',
#     check_field_name  => '"field"',
#     check_field_value => 'value',
#     check_different   => true,
# }

module Puppet

	newtype(:post_restapi) do
		@doc = "Executes a POST to a REST API"

		newparam(:name, :namevar => true) do
			desc "The name of the resource"
		end

		newparam(:url) do
			desc "The URL for the REST service"
		end
		
		newparam(:body) do
			desc "The body for the POST request"
		end

		newparam(:user) do
			desc "The user to connect to the REST service"
		end

		newparam(:password) do
			desc "The password to connect to the REST service"
		end
    
		newparam(:check_field_name) do
			desc "The field name to be checked to verify the sync status of the resource"
		end
    
		newparam(:check_field_value) do
			desc "The field value to be checked to verify the sync status of the resource"
			defaultto ''
		end
    
		newparam(:check_different) do
			desc "A flag indicating wether the check must verify equality or difference"
			defaultto true
		end
    
		validate do
			fail("url parameter is required") if self[:url].nil?
			fail("body parameter is required") if self[:body].nil?
		end

		newproperty(:ensure) do
			desc "Whether the resource is in sync or not."

			defaultto :insync
			
			def fetch(uri_str, limit = 10)
			  require 'uri'
              require 'net/http'
              require 'json'
			
			  # You should choose better exception.
			  raise ArgumentError, 'HTTP redirect too deep' if limit == 0
			
			  url = URI.parse(uri_str)
			  req = Net::HTTP::Get.new(url.path, { 'User-Agent' => 'Puppet call to REST API' })
			  response = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
			  case response
			    when Net::HTTPSuccess     then response
			    when Net::HTTPRedirection then fetch(response['location'], limit - 1)
			    else
			      response.error!
			  end
			end
			
            def post(uri_str, body, limit = 10)
                require 'uri'
                require 'net/http'
                require 'json'

                # You should choose better exception.
                raise ArgumentError, 'HTTP redirect too deep' if limit == 0
				
                url = URI.parse(uri_str)
                response = Net::HTTP.start(url.host, url.port)
                req = Net::HTTP::Post.new(url.path, {'User-Agent' => 'Puppet call to REST API', 'Content-Type' =>'application/json'})
                req.body = "[ " + body.to_json + " ]"
                response.request(req)
            end

			def retrieve
			    if resource[:check_field_name]
			        begin
                        request = fetch(resource[:url])
						response = JSON.parse(request.body)
                        
                        read_val     = eval("response" + resource[:check_field_name])
                        expected_val = eval(resource[:check_field_value])
                        
                        if resource[:check_different]
                            return (read_val == expected_val) ? :insync : :outofsync
                        else
                            return (read_val == expected_val) ? :outofsync : :insync 
                        end
                    rescue Exception => e
                        raise Puppet::Error, "Error while trying to retrieve resource from REST API: #{e}"
                    end
                end
                
                return :outofsync
			end

			newvalue :outofsync
			newvalue :insync do
				debug("Execute_mysql[name] = " + resource[:name] + ".")
				debug("Execute_mysql[url] = " + resource[:url] + ".")
				debug("Execute_mysql[body] = " + resource[:body] + ".")
				debug("Execute_mysql[user] = " + resource[:user] + ".") if resource[:user] 
				debug("Execute_mysql[password] = " + resource[:password] + ".") if resource[:password]
				debug("Execute_mysql[check_field_name] = " + resource[:check_field_name] + ".") if resource[:check_field_name]
				debug("Execute_mysql[check_field_value] = " + resource[:check_field_value] + ".") if resource[:check_field_value]
				debug("Execute_mysql[check_different] = " + resource[:check_different].to_s + ".") if resource[:check_different]
				
				begin 
                    post(resource[:url] + "/", eval(resource[:body]))
				rescue Exception => e
					raise Puppet::Error, "Error while executing POST #{cursql}."
				end # begin
			end # :insync 
		end # ensure
	end # newtype
end # module

