#!/usr/bin/env python

from lxml import etree
import sys
import getopt
from VUKafParserPy import KafParser
from collections import defaultdict
import operator
import pprint
from lxml import etree
import logging



def mix_lists(l1,l2):
  newl=[]
  min_l = min(len(l1),len(l2))
  for x in range(min_l):
    newl.append(l1[x])
    newl.append(l2[x])
  
  if len(l1)>len(l2):
    newl.extend(l1[min_l:])
  elif len(l2)>len(l1):
   newl.extend(l2[min_l:])
  return newl


class OpinionExpression:
    def __init__(self,spans,sentence,value):
        self.ids = spans
        self.sentence = sentence
        self.value = value
        self.target_ids = []
        self.candidates_r=[]
        self.candidates_l=[]
        self.holder = []
    
    def __repr__(self):
        r='Ids:'+'#'.join(self.ids)+' Sent:'+self.sentence+' Value:'+str(self.value)+ ' Target:'+'#'.join(self.target_ids)+'\n'
        r+='Right cand: '+str(self.candidates_r)+'\n'
        r+='Left cand: '+str(self.candidates_l)+'\n'
        return r        
    
class MyToken:
    def __init__(self,id,lemma,pos,polarity,sent_mod,sent):
        self.id = id
        self.lemma = lemma
        self.pos = pos
        self.polarity = polarity
        self.sent_mod = sent_mod
        self.sentence = sent
        self.use_it = True
        self.list_ids = [id]
        self.value = 0
       
       
        if polarity == 'positive':
            self.value = 1
        elif polarity == 'negative':
            self.value = -1
        
        if sent_mod == 'intensifier':
            self.value = 2
        elif sent_mod == 'shifter':
            self.value = -1

    
    def isNegator(self):
        return self.sent_mod == 'shifter'
    

    
    def isIntensifier(self):
        return self.sent_mod == 'intensifier'
    
        
    def is_opinion_expression(self):
        return self.use_it and self.polarity is not None
        
        
    def __repr__(self):
        if self.use_it:
            return self.id+' lemma:'+self.lemma.encode('utf-8')+'.'+self.pos.encode('utf-8')+' pol:'+str(self.polarity)+' sentmod:'+str(self.sent_mod)+' sent:'+self.sentence+' use:'+str(self.use_it)+' list:'+'#'.join(self.list_ids)+' val:'+str(self.value)
        else:
            return '\t'+self.id+' lemma:'+self.lemma.encode('utf-8')+'.'+self.pos.encode('utf-8')+' pol:'+str(self.polarity)+' sentmod:'+str(self.sent_mod)+' sent:'+self.sentence+' use:'+str(self.use_it)+' list:'+'#'.join(self.list_ids)+' val:'+str(self.value)
        
        

def obtain_opinion_expressions(tokens,lang='nl'):
    logging.debug('  Obtaining opinion expressions')
    my_tokens = tokens[:]

    accumulate_several_modifiers = True
    apply_modifiers = True
    apply_conjunctions = True

    ## Acumulate doble/triple intensifiers or negators
    if accumulate_several_modifiers:
        logging.debug('   Accumulating modifiers')
        t = 0
        while t < len(my_tokens):
            if my_tokens[t].isNegator() or my_tokens[t].isIntensifier():
                if t+1 < len(my_tokens) and ( my_tokens[t+1].isNegator() or my_tokens[t+1].isIntensifier()):
                    ## There are 2 negators/intensifiers next to each other
                    ## The first one is deactivated and the second one is modified
                    my_tokens[t].use_it = False
                    my_tokens[t+1].value *= my_tokens[t].value
                    my_tokens[t+1].list_ids += my_tokens[t].list_ids
                    logging.debug('    Accucumating '+'-'.join(my_tokens[t+1].list_ids))
            t+=1
    ###########################################
    
    ##Apply intensifiers/negators over the next elements
    if apply_modifiers:
        logging.debug('   Applying modifiers')
        t = 0
        while t < len(my_tokens):
            if my_tokens[t].use_it and (my_tokens[t].isNegator() or my_tokens[t].isIntensifier()):
                ## Try to modify the next token:
                if t+1<len(my_tokens):
                    my_tokens[t+1].value *= my_tokens[t].value
                    my_tokens[t+1].list_ids += my_tokens[t].list_ids
                    my_tokens[t].use_it = False
                    logging.debug('    Applied modifier over '+'-'.join(my_tokens[t+1].list_ids))
            t += 1
    ###########################################
    
    if apply_conjunctions:
        if lang=='nl':
            concat = [',','en']
        elif lang=='en':
            concat = [',','and']
        elif lang=='es':
            concat = [',','y','e']
        elif lang=='it':
            concat = [',','e','ed']
        elif lang=='de':
            concat = [',','und']
        elif lang == 'fr':
            concat=[',','et']
        logging.debug('  Applying conjunctions:'+str(concat))
            
    
        t = 0
        while t < len(my_tokens):
          if my_tokens[t].use_it and my_tokens[t].value!=0: ## Find the first one
            #print 'FOUND ',my_tokens[t]
            logging.debug('    Found token '+str(my_tokens[t]))
            list_aux = my_tokens[t].list_ids
            used = [t]
            value_aux = my_tokens[t].value
            my_tokens[t].use_it = False
            #print 'Modified',my_tokens[t]
            
            x = t+1
            while True:
                if x>=len(my_tokens):
                    break
                
                if my_tokens[x].lemma in concat:
                    ## list_aux += my_tokens[x].list_ids Dont use it as part of the OE
                    my_tokens[x].use_it = False
                    x+=1
                elif (my_tokens[x].use_it and my_tokens[x].value!=0):
                     #print '\Also ',my_tokens[x]
                     logging.debug('    Found token '+str(my_tokens[x]))
                     list_aux += my_tokens[x].list_ids
                     
                     used.append(x)
                     my_tokens[x].use_it = False
                     value_aux += my_tokens[x].value
                     x += 1
                else:
                    break
            #print 'OUT OF THE WHILE'
            ##The last one in the list used is the one accumulating all
            
            last_pos = used[-1]
            my_tokens[last_pos].value = value_aux
            my_tokens[last_pos].list_ids = list_aux
            my_tokens[last_pos].use_it = True
            logging.debug('    Regenerating '+str(my_tokens[last_pos]))
            t = x ## next token
            #print
            #print
          t += 1
      
      
    ## Create OpinionExpression
    my_opinion_exps = []
    logging.debug('   Generating output')
    for token in my_tokens:
        if token.use_it and token.value != 0:
            op_exp = OpinionExpression(token.list_ids,token.sentence,token.value)
            my_opinion_exps.append(op_exp)
    return my_opinion_exps


'''   
def get_distance(id1, id2):
    pos1 = int(id1[id1.find('_')+1:])
    pos2 = int(id2[id2.find('_')+1:])
    if pos1>pos2:
        return pos1-pos2
    else:
        return pos2-pos1
'''
   

def obtain_holders(ops_exps,sentences,lang):
    if lang=='nl':
        holders = ['ik','we','wij','ze','zij','jullie','u','hij','het','jij','je','mij','me','hem','haar','ons','hen','hun']
    elif lang=='en':
        holders = ['i','we','he','she','they','it','you']
    elif lang =='es':
        holders = ['yo','tu','nosotros','vosotros','ellos','ellas','nosotras','vosotras']
    elif lang =='it':
        holders = ['io','tu','noi','voi','loro','lei','lui']
    elif lang == 'de':
        holders = ['ich','du','wir','ihr','sie','er']
    elif lang == 'fr':
        holders = ['je','tu','lui','elle','nous','vous','ils','elles']
        
    logging.debug('Obtaining holders with list: '+str(holders))
        
    for oe in ops_exps:
        sent = oe.sentence
        list_terms = sentences[str(sent)]
        for lemma, pos, term_id in list_terms:
            if lemma in holders:
                oe.holder.append(term_id)
                logging.debug('  Selected for '+str(oe)+' holder'+lemma+' '+term_id)
                break




#This is specific for the basic version
def filter_candidates(candidates,ids_oe):
  ##filtered  = [(lemma, pos,term_id) for (lemma,pos, term_id) in candidates if len(lemma)>=4 and term_id not in ids_oe]
  filtered = [(lemma,pos,id) for (lemma,pos,id) in candidates if pos in ['N','R']]
  return filtered

def obtain_targets_improved(ops_exps,sentences):
    logging.debug('  Obtaining targets improved')
    #print>>sys.stderr,'#'*40
    #print>>sys.stderr,'#'*40
    
    #print>>sys.stderr,'Beginning with obtain targets'
    ##sentences --> dict   [str(numsent)] ==> list of (lemma, term)id
    
    all_ids_in_oe = []
    for oe in ops_exps:
        all_ids_in_oe.extend(oe.ids)
    #print>>sys.stderr,'All list of ids in oe',all_ids_in_oe
    
    for oe in ops_exps:
        #print>>sys.stderr,'\tOE:',oe
        logging.debug('   OpExp: '+str(oe))
        
        ids_in_oe = oe.ids
        sent = oe.sentence
        list_terms = sentences[str(sent)]
        #print>>sys.stderr,'\t\tTerms in sent:',list_terms
        
        ###########################################
        #First rule: noun to the right within maxdistance tokens
        max_distance_right = 3
        biggest_index = -1
        for idx, (lemma,pos,term_id) in enumerate(list_terms):
            if term_id in ids_in_oe:
                biggest_index = idx
        
        #print>>sys.stderr,'\t\tBI',biggest_index
        if biggest_index+1 >= len(list_terms):  ## is the last element and we shall skip it
            #print>>sys.stderr,'\t\tNot possible to apply 1st rule'
            pass
        else:
            candidates=list_terms[biggest_index+1:min(biggest_index+1+max_distance_right,len(list_terms))]
            ##Filter candidates
            #print>>sys.stderr,'\t\tCandidates for right rule no filter',candidates
            #oe.__candidates_right = [(lemma, term_id) for (lemma, term_id) in candidates if len(lemma)>=4 and term_id not in all_ids_in_oe]
            oe.candidates_r = filter_candidates(candidates,all_ids_in_oe)
            logging.debug('  Candidates filtered right'+str(oe.candidates_r))
            #print>>sys.stderr,'\t\tCandidates for right rule no filter',oe.__candidates_right

        ######################################################################################
        

        ###########################################
        max_distance_left = 3
        smallest_index = 0
        for idx,(lemma,pos,term_id) in enumerate(list_terms):
            if term_id in ids_in_oe:
                smallest_index = idx
                break
        #print>>sys.stderr,'Smalles index:',smallest_index
        if smallest_index == 0:
            #print>>sys.stderr,'\t\tNot possible to apply left rule'
            pass
        else:
            candidates = list_terms[max(0,smallest_index-1-max_distance_left):smallest_index]
            ##Filter candidates
            #print>>sys.stderr,'\t\tCandidates for left rule no filter',candidates

            oe.candidates_l = filter_candidates(candidates,all_ids_in_oe)
            logging.debug('  Candidates filtered left: '+str(oe.candidates_l))

        ######################################################################################   
        
    #print>>sys.stderr,'#'*40
    #print>>sys.stderr,'#'*40
    
    ## filling or.target_ids
    assigned_as_targets = []
    
    # First we assing to all the first in the right, if any, and not assigned
    logging.debug(' Applying first to the right rule')
    for oe in ops_exps:
        #print>>sys.stderr,'A ver ',oe
        if len(oe.candidates_r) !=0:
            lemma, pos, id = oe.candidates_r[0]
            if id not in assigned_as_targets:
              oe.target_ids.append(id)
              ###assigned_as_targets.append(id) 	#Uncomment to avoid selection of the same target moe than once
              logging.debug('  OpExp '+str(oe)+' selected '+id)
              #print>>sys.stderr,'Asignamos',id
    
    logging.debug(' Applying most close rule')
    for oe in ops_exps:
        if len(oe.target_ids) == 0:  # otherwise it's solved
            intercalados_list = mix_lists([id for _,_,id in oe.candidates_r],[id for _,_,id in oe.candidates_l])
            for id in intercalados_list:
                if id not in assigned_as_targets:
                    oe.target_ids.append(id)
                    ###assigned_as_targets.append(id)	#Uncomment to avoid selection of the same target moe than once
                    logging.debug('  OpExp '+str(oe)+' selected '+id)
                    break

######## MAIN ROUTINE ############                

## Check if we are reading from a pipeline
if sys.stdin.isatty():
    print>>sys.stderr,'Input stream required.'
    print>>sys.stderr,'Example usage: cat myUTF8file.kaf.xml |',sys.argv[0]
    sys.exit(-1)
########################################

logging.basicConfig(stream=sys.stderr,format='%(asctime)s - %(levelname)s - %(message)s',level=logging.DEBUG)

## Processing the parameters
my_time_stamp = True
remove_opinions = True
opinion_strength = True
try:
    opts, args = getopt.getopt(sys.argv[1:],"",["no-time","no-remove-opinions","no-opinion-strength"])
    for opt, arg in opts:
        if opt == "--no-time":
            my_time_stamp = False
        elif opt == "--no-remove-opinions":
            remove_opinions = False
        elif opt == "--no-opinion-strength":
            opinion_strength = False
except getopt.GetoptError:
    pass
#########################################

logging.debug('Include timestamp: '+str(my_time_stamp))

# Parsing the KAF file
try:
    my_kaf_tree = KafParser(sys.stdin)
except Exception as e:
    print>>sys.stderr,'Error parsing input'
    print>>sys.stderr,'Stream input must be a valid KAF file'
    print>>sys.stderr,'Error: ',str(e)
    sys.exit(-1)
    
    
lang = my_kaf_tree.getLanguage()
## Creating data structure
sentences = defaultdict(list)
my_tokens = []


# CREATE the datastructure for the tokens
n=0
lemma_for_tid = {}
for term in my_kaf_tree.getTerms():
    n+=1
    term_id = term.getId()
    lemma = term.getLemma()
    lemma_for_tid[term_id] = lemma
    kaf_pos = term.getPos()
    #print>>sys.stderr,kaf_pos
    list_span = term.get_list_span()        ## List of token ids in the span layer of the term
    sentiment = term.getSentiment()
    polarity = sent_mod = None
    if sentiment is not None:
        polarity = sentiment.getPolarity()
        sent_mod = sentiment.getSentimentModifier()
    sentence = my_kaf_tree.getToken(list_span[0]).get('sent')   ## The sentence of the first token element in span
    my_tokens.append(MyToken(term_id,lemma,kaf_pos,polarity,sent_mod,sentence))
    
    sentences[str(sentence)].append((lemma,kaf_pos,term_id))
#############################

logging.debug('Num terms loaded: '+str(n))
logging.debug('Num sentences: '+str(len(sentences)))


logging.debug('Obtaining opinion expressions')
my_ops_exps = obtain_opinion_expressions(my_tokens,lang)
print>>sys.stderr,my_ops_exps

logging.debug('Obtaining targets')
obtain_targets_improved(my_ops_exps,sentences)


logging.debug('Obtaining holders')
obtain_holders(my_ops_exps,sentences,lang)




## Create the elements
logging.debug('Generating KAF output')

if remove_opinions:
    my_kaf_tree.remove_opinion_layer()
    
for oe in my_ops_exps:
    op_ele = etree.Element('opinion')
    
    ## Holder
    if len(oe.holder)!=0:
      oe.holder.sort()
      c = ' '.join(lemma_for_tid[tid] for tid in oe.holder)
      op_hol = etree.Element('opinion_holder')
      op_hol.append(etree.Comment(c))
      op_ele.append(op_hol)
      span_op_hol = etree.Element('span')
      op_hol.append(span_op_hol)
      for id in oe.holder:
        span_op_hol.append(etree.Element('target',attrib={'id':id}))
    
    ## Target
    op_tar = etree.Element('opinion_target')
    op_ele.append(op_tar)

    
    if len(oe.target_ids)!=0:   ## if there are no targets, there is no opinion eleemnt
      oe.target_ids.sort()
      c = ' '.join(lemma_for_tid[tid] for tid in oe.target_ids)
      op_tar.append(etree.Comment(c)) 
      span_op_tar = etree.Element('span')
      op_tar.append(span_op_tar)
      for id in oe.target_ids:
        span_op_tar.append(etree.Element('target',attrib={'id':id}))
        
    #Expression
    if oe.value > 0:  pol = 'positive'
    elif oe.value < 0: pol = 'negative'
    else:  pol = 'neutral'
        
    op_exp = etree.Element('opinion_expression')
    op_exp.set('polarity',pol)
    if opinion_strength:
        op_exp.set('strength',str(oe.value))
  
    op_ele.append(op_exp)
    oe.ids.sort()
    c = ' '.join(lemma_for_tid[tid] for tid in oe.ids)   
    op_exp.append(etree.Comment(c)) 
    span_exp = etree.Element('span')
    op_exp.append(span_exp)
    for id in oe.ids:
      span_exp.append(etree.Element('target',attrib={'id':id}))
        
    ##Append the op_ele to the opinions layer
    my_kaf_tree.addElementToLayer('opinions', op_ele)
        
    
my_kaf_tree.addLinguisticProcessor('Basic opinion detector with Pos','1.0','opinions', my_time_stamp)    
my_kaf_tree.saveToFile(sys.stdout)
logging.debug('Process finished')


    

