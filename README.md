# 3scale API gateway cookbook

This [cookbook](https://github.com/3scale/chef-3scale) installs the 3scale API gateway. [3scale](http://www.3scale.net/platform-features/) is an API management platform that makes it easy to open, distribute, control, and monetize your API. The API gateway is the simplest and most performant way to integrate your API with the 3scale platform.

Running the cookbook will install [Openresty](http://openresty.org/), which the 3scale API gateway is based upon, plus all the required system dependencies. 

The cookbook not only installs the API gateway but it will also deploy your 3scale Nginx configuration files, specifically tailored for your API configuration. The result of running this cookbook will be an up-and-running API gateway listening for incoming authenticated requests.

## Attributes

There are 4 attributes that you will need to set to configure how you use the cookbook. All of them are under the `3scale` namespace:


| Attribute                                | Description      |Default                      |
|:-----------------------------------------|:-------------|:---------------------------------|
| `['3scale']['config-source']`                | Where your Nginx configuration files will be taken from. Three options: "local", "url" or "3scale". More on this the section “Applying your own 3scale configuration”.    | `'local'`
| `['3scale']['provider-key']`                 | The key that identifies you as a 3scale customer. It can be found in the "Account" menu of your 3scale admin portal. | `'REPLACE_WITH_3SCALE_PROVIDER_KEY'`
| `['3scale']['admin-domain']`               | If your 3scale admin portal domain is "mycompany-admin.3scale.net", then the value of this attribute should be "mycompany". | `'REPLACE_WITH_3SCALE_ADMIN_URL_PART'`
| `['3scale']['config-version']` | Version id. If not included, the current configuration from your 3scale account will be used.  If included, the value must be a timestamp of one deployment, formatted like in the following example: "2015-09-15-041532". See the "Rollback process" section for more information on this. | `nil`
| `['3scale']['config-url']` | URL endpoint from where the configuration files are downloaded when `[3scale][config-source] = "url"`. The URL endpoint pointed here should host a zip bundle with the files. Example: "https://s3.amazonaws.com/my-bucket-name/bundle.zip"  | `nil`


The default value for each of those attributes is defined [here](https://github.com/3scale/chef-3scale/blob/master/attributes/default.rb).


This cookbook uses and depends on the [Openresty cookbook](https://github.com/priestjim/chef-openresty). Therefore attributes of that cookbook are also available to you. You can see a full list [here](https://github.com/priestjim/chef-openresty#attributes). 

Since you will be using the Nginx configuration files that 3scale generates for you, you will not be able to use the attributes of the Openresty cookbook that are related to configuration parameters that go in the nginx.conf file.

## Usage

Include `chef-3scale` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[chef-3scale::default]"
  ]
}
```

## Applying your own 3scale configuration

For the API gateway to be configured for your own API endpoints, you need to deploy it using your own set of Nginx configuration files. 

There are three ways to apply your own configuration files to the cookbook:

### Option 1: Local configuration files 

configure your API in 3scale using the “On-premise Gateway” option
click on “Download the Nginx Config files” at the bottom of the screen
drop those files on the  `/files/default/config/` directory of the cookbook 

To use this option you will need to set the `['3scale']['config-source']` attribute to `“local”` in your node or role description.

###  Option 2: Fetch configuration files from your 3scale account

With this option the cookbook will automatically fetch the Nginx configuration files from your 3scale account when running the deployment.

To use this option you will need to set the following attributes in your node or role description:  

- **['3scale']['config-source']** = “3scale”   
- **['3scale']['provider-key']**  = (see attributes section)  
- **['3scale']['admin-domain']**  = (see attributes section)  

### Option 3: Fetch configuration files from any URL endpoint

With this option the cookbook will automatically fetch the Nginx configuration files from the URL endpoint specified in the `[3scale][config-ur]` attribute. That endpoint should host a zip bundle of the configuration files.
  
To use this option you will need to set the following attributes in your node or role description:  

- **['3scale']['config-source']** = “url”   
- **['3scale']['config-url']**    = (see attributes section)  
  

#### Note
In all three deployment options the Nginx configuration files will be copied to a subdirectory in the `/var/chef/cache/` and symlinked to the Nginx working directory (`/etc/nginx/`).

## Rollback process

The chef-3scale cookbook allows rolling back to a previously deployed version of the configuration. This is useful if you have a node where the API gateway had already been deployed one or multiple times, and you want to deploy it again but using the configuration files from one of the previous deployments instead of using the latest version.

The built-in way to roll back is by using the `['3scale']['config-version']` attribute. Here is an example of a full node description using the rollback attribute:


```json
{
  "3scale": {
    "provider-key": "YOURPROVIDERKEY",
    "admin-domain": "mycompany",
    "config-version": "2015-09-15-050545"
  },
  "openresty": {
    "source": {
      "prefix": "/etc"
    }
  },
  "run_list": [
    "recipe[chef-3scale::default]"
  ]
}
```

The value of the attribute must be the timestamp generated by the cookbook when running a deployment. This attribute is always logged and printed to the screen while running the cookbook:

```
 3SCALE - deploying gateway with LATEST configuration version: 2015-09-15-050545
```

When a gateway has been deployed using one of the previous versions of the configuration, the logged message will be slightly different:

```
 3SCALE - rolling back to configuration version: 2015-09-15-050545
```

The rollback process will symlink the configuration files located at:

```
  /var/chef/cache/<config-version-attribute>/*
```

to the Nginx configuration directory and then reload the gateway.

## Troubleshooting

If you are having problems deploying your API gateway when running the cookbook, then the best first step is to look at Chef’s own logs. Here you can find some useful debugging tips: https://docs.chef.io/debug.html

If the deployment completed successfully but the issue is that the API gateway is not running as expected, then the problem most probably is in the Nginx configuration files you deployed. The best place to start troubleshooting is the Nginx error log, located at `/var/log/nginx/error.log`

If there are no errors in the Nginx log, you might want to double check how you have configured your API in 3scale. There are plenty of resources available on our [support portal](https://support.3scale.net), such as [this debugging guide](https://support.3scale.net/howtos/api-configuration#debugging).

## Supported platforms

This cookbook has been tested on the following platforms:

- Ubuntu (versions: 14.04 LTS)  
- CentOS (versions: 7.1, 6.7)  

It has been tested with Chef 11 and Chef 12.  

## License and Authors

Author:: Victor Delgado (<victor@3scale.net>)

```text
The MIT License (MIT)

Copyright (c) 2015 3scale Inc. (https://3scale.net)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

