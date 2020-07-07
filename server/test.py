from qcsubmit.factories import BasicDatasetFactory  # load in the factory to process molecules
from qcsubmit import workflow_components            	# load in a list of workflow_components
from openforcefield.utils.utils import get_data_file_path  # a util function to load a mini drug bank file
from openforcefield.topology import Molecule

factory = BasicDatasetFactory()
# we can view and change any of the basic settings in the factory such as the qm settings
#factory.program = 'torchani'
factory.method = 'hf'
factory.basis = "6-311G"
factory.driver = 'energy'
#factory.spec_description = "ANI1ccx standard specification"
#factory.spec_name = "ani1ccx"
# lets look at the class and the settings
print(factory)
mol = Molecule.from_smiles('NCCN')
mol.generate_conformers()
for i in range(100):
	new_conf = mol.conformers[0]
	new_conf[0][0] *= 0.95 + (0.001 * i)
	mol.add_conformer(new_conf)
dataset = factory.create_dataset(dataset_name='my_dataset',
                             	molecules=[mol],
                             	description='a minimal torsion drive',
                             	tagline='this summers most anticipated release')
import qcportal as ptl
client = ptl.FractalClient('192.168.176.1:7777', verify=False)
print("server info:", client.server_information())
dataset.metadata.long_description_url = "https://test.org"
dataset.submit(client)
