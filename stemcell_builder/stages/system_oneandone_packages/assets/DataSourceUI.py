# vi: ts=4 expandtab
#
#    Author: Jorge Jimenez (United Internet)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License version 3, as
#    published by the Free Software Foundation.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

from cloudinit import log as logging
from cloudinit import util
from cloudinit import sources
from cloudinit import url_helper
from types import *
import json


LOG = logging.getLogger(__name__)

BUILTIN_DS_CONFIG = {
    'metadata_url': 'http://169.254.169.254/latest/'
}
MD_TIMEOUT = 5
MD_RETRIES = 3
MD_SEC_BETWEEN = 1

class DataSourceUI(sources.DataSource):
    def __init__(self, sys_cfg, distro, paths):
        sources.DataSource.__init__(self, sys_cfg, distro, paths)
        self.metadata = dict()
        self.ds_cfg = util.mergemanydict([
            util.get_cfg_by_path(sys_cfg, ["datasource", "UI"], {}),
            BUILTIN_DS_CONFIG])
        self.metadata_address = self.ds_cfg['metadata_url']
        self.timeout = self.ds_cfg.get('timeout', MD_TIMEOUT)
        self.retries = self.ds_cfg.get('retries', MD_RETRIES)
        self.sec_between = self.ds_cfg.get('sec_between', MD_SEC_BETWEEN)

    def _path_read(self, path):
        response = url_helper.readurl(path,
                                      timeout=self.timeout,
                                      retries=self.retries,
                                      sec_between=self.sec_between)
        if type(response.contents) is str:
            return response.contents
        else:
            return response.contents.decode()

    def get_data(self):
        self.metadata = json.loads(self._path_read(self.metadata_address + 'meta_data.json'))
        self.userdata_raw = self._path_read(self.metadata_address + 'ui_data')
        self.vendordata_raw = self._path_read(self.metadata_address + 'vendor_data')
        if self.get_instance_id():
            return True
        else:
            return False

    def get_public_ssh_keys(self):
        return self.metadata.get('public_keys')

    @property
    def availability_zone(self):
        return self.metadata.get('datacenter')

    def get_instance_id(self):
        return self.metadata.get('server_id')

    def get_locale(self):
        return self.metadata.get('locale', 'en_US.UTF-8')

    def get_hostname(self, fqdn=False):
        return self.metadata.get('hostname')

    @property
    def launch_index(self):
        return None

# Used to match classes to dependencies
datasources = [
  (DataSourceUI, (sources.DEP_FILESYSTEM, sources.DEP_NETWORK)),
  ]

# Return a list of data sources that match this set of dependencies
def get_datasource_list(depends):
    return sources.list_from_depends(depends, datasources)
