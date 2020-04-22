require "file_utils"
require "colorize"
require "totem"

def helm_installations(verbose=false)
  gmsg = "No Global helm version found"
  lmsg = "No Local helm version found"
  ghelm = helm_global_response
  puts ghelm if verbose
  
  global_helm_version = helm_version(ghelm, verbose)
   
  if global_helm_version
    gmsg = "Global helm found. Version: #{global_helm_version}"
    puts gmsg.colorize(:green)
  else
    puts gmsg.colorize(:yellow)
  end

  lhelm = helm_local_response
  puts lhelm if verbose
  
  local_helm_version = helm_version(lhelm, verbose)
   
  if local_helm_version
    lmsg = "Local helm found. Version: #{local_helm_version}"
    puts lmsg.colorize(:green)

  else
    puts lmsg.colorize(:yellow)
  end

  if !(global_helm_version && local_helm_version)
    puts "Helm not found".colorize(:red)
  end
  "#{lmsg} #{gmsg}"
end 

def helm_global_response(verbose=false)
  helm_response = `helm version`
  puts helm_response if verbose
  helm_response 
end

def helm_local_response(verbose=false)
  current_dir = FileUtils.pwd 
  puts current_dir if verbose 
  helm = "#{current_dir}/#{TOOLS_DIR}/helm/linux-amd64/helm"
  helm_response = `#{helm} version`
  puts helm_response if verbose
  helm_response
end

def helm_version(helm_response, verbose=false)
  resp = "#{helm_v2_version(helm_response) || helm_v3_version(helm_response)}"
  puts resp if verbose
  resp
end


def helm_v2_version(helm_response)
  # example
  # Client: &version.Version{SemVer:\"v2.14.3\", GitCommit:\"0e7f3b6637f7af8fcfddb3d2941fcc7cbebb0085\", GitTreeState:\"clean\"}\nServer: &version.Version{SemVer:\"v2.16.1\", GitCommit:\"bbdfe5e7803a12bbdf97e94cd847859890cf4050\", GitTreeState:\"clean\"}
  helm_v2 = helm_response.match /Client: &version.Version{SemVer:\"(v([0-9]{1,3}[\.]){2}[0-9]{1,3})"/
  helm_v2 && helm_v2.not_nil![1]
end

def helm_v3_version(helm_response)
  # example
  # version.BuildInfo{Version:"v3.1.1", GitCommit:"afe70585407b420d0097d07b21c47dc511525ac8", GitTreeState:"clean", GoVersion:"go1.13.8"}
  helm_v3 = helm_response.match /BuildInfo{Version:\"(v([0-9]{1,3}[\.]){2}[0-9]{1,3})"/
  helm_v3 && helm_v3.not_nil![1]
end