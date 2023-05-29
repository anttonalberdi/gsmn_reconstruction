
#pip install cobra
#python

import os
import logging
import cobra
from collections import Counter


#############
# DECLARE FUNCTIONS
#############


#Create dictionary of metabolites with
## Number of reactions per metabolite
## Number of reactant roles per metabolite
## Number of product roles per metabolite
def metabolite_dictionary(model):
    metdict = {}
    for metabolite in model.metabolites:
        reactants = []
        products = []
        reactions = list(metabolite.reactions)
        for reaction in metabolite.reactions:
            for reactant in reaction.reactants:
                reactants.append(reactant.id)
            for product in reaction.products:
                products.append(product.id)
        metdict[metabolite.id] = [len(reactions),reactants.count(metabolite.id),products.count(metabolite.id)]
    return metdict

def list_reactions(model):
    list_reactions = []
    for reaction in model.reactions:
        list_reactions.append(reaction.id)
    return list_reactions

#List sources (metabolites that the genome is unable to produce)
#Only list metabolites that act as reactants but not as products
def sources(metabolite_dictionary):
    sources=[]
    for key, value in metabolite_dictionary.items():
        if value[1] > 0 and value[2] == 0:
            sources.append(key)
    return sources

#List products
#List metabolites that act as products regardless they are reactants
def products(metabolite_dictionary):
    products=[]
    for key, value in metabolite_dictionary.items():
        if value[2] > 0:
            products.append(key)
    return products

#List sinks
#Only list metabolites that act as products but not as reactants
def sinks(metabolite_dictionary):
    sinks=[]
    for key, value in metabolite_dictionary.items():
        if value[1] == 0 and value[2] > 0:
            sinks.append(key)
    return sinks

#List metabolites that model1 generates and model2 requires but is unable to generate
def dependence(model1, model2):
    model1_dict = metabolite_dictionary(model1)
    model1_products = set(products(model1_dict))
    model2_dict = metabolite_dictionary(model2)
    model2_sources = set(sources(model2_dict))
    dependence = model1_products.intersection(model2_sources)
    return dependence

#List metabolites that model1 generates and does not metabolise, and model2 requires but is unable to generate
def dependence_hard(model1, model2):
    model1_dict = metabolite_dictionary(model1)
    model1_sinks = set(sinks(model1_dict))
    model2_dict = metabolite_dictionary(model2)
    model2_sources = set(sources(model2_dict))
    dependence_hard = model1_sinks.intersection(model2_sources)
    return dependence_hard

def reaction_similarity(model1, model2):
    model1_reactions = list_reactions(model1)
    model2_reactions = list_reactions(model2)
    intersect = len(set(model1_reactions).intersection(set(model2_reactions)))
    total = len(set(model1_reactions + model2_reactions))
    reaction_similarity = round(intersect / total,2)
    return reaction_similarity

def metabolite_similarity(model1, model2):
    model1_metabolites = list(metabolite_dictionary(model1).keys())
    model2_metabolites = list(metabolite_dictionary(model2).keys())
    intersect = len(set(model1_metabolites).intersection(set(model2_metabolites)))
    total = len(set(model1_metabolites + model2_metabolites))
    metabolite_similarity = round(intersect / total,2)
    return metabolite_similarity

#############
# Dependence between ERR4836965_bin_9 (Campylobacter coli) and the rest of genomes
#############

#Reduce logging of cobra to avoid printing warning messages
logging.getLogger('cobra').setLevel(logging.ERROR)

# load dependent genome
model2 = cobra.io.read_sbml_model("genomes/ERR4836965_bin_9.sbml")

# iterate over files in directory
directory = 'genomes/'
with open("dependency_ERR4836965_bin_9.tsv", "a") as results:
    for filename in os.listdir(directory):
        if filename.endswith('.sbml'):
            model1 = cobra.io.read_sbml_model(os.path.join(directory, filename))
            print(model1.id)
            value = len(dependence(model1, model2))
            row = "\t".join([model1.id, model2.id, str(value)])
            _ = results.write(row + "\n")

#############
# Dependence between ERR4836918_bin_11 (Campylobacter jejuni) and the rest of genomes
#############

# load dependent genome
model2 = cobra.io.read_sbml_model("genomes/ERR4836918_bin_11.sbml")

# iterate over files in directory
directory = 'genomes/'
with open("dependency_ERR4836918_bin_11.tsv", "a") as results:
    for filename in os.listdir(directory):
        if filename.endswith('.sbml'):
            model1 = cobra.io.read_sbml_model(os.path.join(directory, filename))
            print(model1.id)
            value = len(dependence(model1, model2))
            row = "\t".join([model1.id, model2.id, str(value)])
            _ = results.write(row + "\n")













ERR4968581_bin_26 = cobra.io.read_sbml_model("recon/sbml/ERR4968581_bin_26.sbml")
ERR4836965_bin_9 = cobra.io.read_sbml_model("recon2/sbml/ERR4836965_bin_9.sbml")
ERR4836918_bin_11 = cobra.io.read_sbml_model("recon2/sbml/ERR4836918_bin_11.sbml")
ERR4968588_bin_12 = cobra.io.read_sbml_model("recon2/sbml/ERR4968588_bin_12.sbml")
ERR4303154bin_37 = cobra.io.read_sbml_model("recon2/sbml/ERR4303154bin_37.sbml")
ERR4968604_bin_20 = cobra.io.read_sbml_model("recon2/sbml/ERR4968604_bin_20.sbml")
ERR4304450bin_69 = cobra.io.read_sbml_model("recon2/sbml/ERR4304450bin_69.sbml")
ERR7167041_bin_33 = cobra.io.read_sbml_model("recon2/sbml/ERR7167041_bin_33.sbml")
ERR4836959_bin_22 = cobra.io.read_sbml_model("recon2/sbml/ERR4836959_bin_22.sbml")
ERR7167033_bin_2 = cobra.io.read_sbml_model("recon2/sbml/ERR7167033_bin_2.sbml")


len(dependence(ERR7167041_bin_33, ERR4836965_bin_9))


#How much can contribute Bacillus subtilis_A (ERR4968581_bin_26) to Campylobacter coli (ERR4836965_bin_9)?
dependence(ERR4968581_bin_26, ERR4836965_bin_9)
dependence_hard(ERR4968581_bin_26, ERR4836965_bin_9)

#How much can contribute Bacillus subtilis_A (ERR4968581_bin_26) to Campylobacter jejuni (ERR4836918_bin_11)?
dependence(ERR4968581_bin_26, ERR4836918_bin_11)
dependence_hard(ERR4968581_bin_26, ERR4836918_bin_11)

#Metabolite similarity between Campylobacter coli (ERR4836965_bin_9) and Campylobacter jejuni (ERR4836918_bin_11)
metabolite_similarity(ERR4836965_bin_9,ERR4836918_bin_11)

#Reaction similarity between Campylobacter coli (ERR4836965_bin_9) and Campylobacter jejuni (ERR4836918_bin_11)
reaction_similarity(ERR4836965_bin_9,ERR4836918_bin_11)







########################

#Load model
model = cobra.io.read_sbml_model("recon2/sbml/ERR4836918_bin_11.sbml")
model = cobra.io.read_sbml_model("recon2/sbml/ERR4836965_bin_9.sbml")
model = cobra.io.read_sbml_model("recon/sbml/ERR4968581_bin_26.sbml")

#Create dictionary of number of reactions, reactants and products
metdict = {}
for metabolite in model.metabolites:
    reactants = []
    products = []
    reactions = list(metabolite.reactions)
    for reaction in metabolite.reactions:
        for reactant in reaction.reactants:
            reactants.append(reactant.id)
        for product in reaction.products:
            products.append(product.id)
    metdict[metabolite.id] = [len(reactions),reactants.count(metabolite.id),products.count(metabolite.id)]

#List sources (metabolites that the genome is unable to produce)
#Only list metabolites that act as reactants but not as products
sources=[]
for key, value in metdict.items():
    if value[1] > 0 and value[2] == 0:
        sources.append(key)

#List products
#List metabolites that act as products regardless they are reactants
products=[]
for key, value in metdict.items():
    if value[2] > 0:
        products.append(key)

#List sinks
#Only list metabolites that act as products but not as reactants
sinks=[]
for key, value in metdict.items():
    if value[1] == 0 and value[2] > 0:
        sinks.append(key)

len(model.metabolites)
len(model.reactions)
len(sources)
len(products)
len(sinks)

######
# Save metabolites of key bacteria
######

Bacteroides_products=products
Bacteroides_sinks=sinks

Cjejuni_sources=sources
Ccoli_sources=sources

#Bacteroides products to C jejuni
Bacteroides_products_set = set(Bacteroides_products)
Cjejuni_sources_set = set(Cjejuni_sources)
len(Bacteroides_products_set.intersection(Cjejuni_sources_set))

#Bacteroides sinks to C jejuni
Bacteroides_sinks_set = set(Bacteroides_sinks)
Cjejuni_sources_set = set(Cjejuni_sources)
len(Bacteroides_sinks_set.intersection(Cjejuni_sources_set))

#Bacteroides products to C coli
Bacteroides_products_set = set(Bacteroides_products)
Ccoli_sources_set = set(Ccoli_sources)
len(Bacteroides_products_set.intersection(Ccoli_sources_set))

#Bacteroides products to C coli
Bacteroides_sinks_set = set(Bacteroides_sinks)
Ccoli_sources_set = set(Ccoli_sources)
len(Bacteroides_sinks_set.intersection(Ccoli_sources_set))
