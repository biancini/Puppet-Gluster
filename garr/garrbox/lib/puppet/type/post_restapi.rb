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

			def retrieve
			    if resource[:check_field_name]
			        begin
                        require 'uri'
                        require 'net/http'
                        require 'json'
                
                        request = Net::HTTP::Get.new(resource[:url])
                        
                        uri      = URI.parse(resource[:url])
                        http     = Net::HTTP.new(uri.host, uri.port)
                        response = JSON.parse(http.request(request))
                        
                        read_val     = eval("reponse" + resource[:check_field_name])
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
				debug("Execute_mysql[user] = " + resource[:user] + ".")
				debug("Execute_mysql[password] = " + resource[:password] + ".")
				debug("Execute_mysql[check_field_name] = " + resource[:check_field_name] + ".")
				debug("Execute_mysql[check_field_value] = " + resource[:check_field_value] + ".")
				debug("Execute_mysql[check_different] = " + resource[:check_different].to_s + ".")
				
				begin 
					require 'uri'
                    require 'net/http'
                    require 'json'
            
                    request = Net::HTTP::Post.new(resource[:url])
                    #request.add_field "Content-Type", "application/xml"
                    request.body = resource[:body]

                    uri = URI.parse(resource[:url])
                    http = Net::HTTP.new(uri.host, uri.port)
                    response = http.request(request)
				rescue Exception => e
					raise Puppet::Error, "Error while executing POST #{cursql}."
				end # begin
			end # :insync 
		end # ensure
	end # newtype
end # module

