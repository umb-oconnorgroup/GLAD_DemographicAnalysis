import os
import os.path

import sys
import gzip
import argparse
import numpy as np

class DB:
    def __init__(self, name, fb, msp, ibd):
        self.fb = fb
        self.msp = msp
        self.ibd = ibd
        self.name = name

    def getLocalAncestryFiles(self):
        return self.fb, self.msp

    def getIBD(self):
        return self.ibd

class genome():
    def __init__(self):
        self.chromosomes = {}

    def insertTract(self, chr, startBP, startMorgan, endBP, endMorgan, haplotype, anc):
        if chr not in self.chromosomes:
            self.chromosomes[chr] = chromosome()

        self.chromosomes[chr].insertTractInHaplotype(startBP, startMorgan, endBP, endMorgan, haplotype, anc)

    def getTracts(self, chr, haplotype, posBPStart, posBPEnd):
        tracts = self.chromosomes[chr].getTractsChromosomes(haplotype, posBPStart, posBPEnd)
        return tracts

    def printChr(self):
        for chromosome in self.chromosomes:
            print(f"CHR: {chromosome}")
            self.chromosomes[chromosome].printTracts()
class chromosome:
    def __init__(self):
        self.haplotype1 = []
        self.haplotype2 = []

    def getTractsChromosomes(self, haplotype, posBPStart, posBPEnd):
        returnData = []
        if haplotype == 1:
            for tract in self.haplotype1:
                #print(f"\033[94m{posBPStart}\033[0m <= {tract.getEndBP()} e \033[94m{posBPEnd}\033[0m >= {tract.getStartBP()}", end = "")
                if posBPStart <= tract.getEndBP():
                    #print("In1 --> ", end = "")
                    if posBPEnd >= tract.getStartBP():
                        #print("In2 --> ", end="")
                        returnData.append(tract)
                #print("\n")
                #else:
                #    if posBPEnd <= tract.getStartBP():
                #        break

        else:
            for tract in self.haplotype1:
                #print(f"\033[94m{posBPStart}\033[0m <= {tract.getEndBP()} e \033[94m{posBPEnd}\033[0m >= {tract.getStartBP()}", end = "")
                if posBPStart <= tract.getEndBP():
                    #print("In1 --> ", end = "")
                    if posBPEnd >= tract.getStartBP():
                        #print("In2 --> ", end="")
                        returnData.append(tract)
                #print("\n")
                #else:
                #    if posBPEnd <= tract.getStartBP():
                #        break

        #getchar()
        return returnData


    def insertTractInHaplotype(self, startBP, startMorgan, endBP, endMorgan, haplotype, anc):
        if haplotype == 1:
            if not self.haplotype1:
                self.haplotype1.append(tracts(anc, startBP, startMorgan))
                self.haplotype1[-1].setEnd(endBP, endMorgan)
            else:
                if self.haplotype1[-1].isTheSameAncestry(anc):
                    self.haplotype1[-1].setEnd(endBP, endMorgan)
                else:
                    #self.haplotype1[-1].setEnd(endBP, previousMorgan)
                    self.haplotype1.append(tracts(anc, startBP, startMorgan))
                    self.haplotype1[-1].setEnd(endBP, endMorgan)
        else:
            if not self.haplotype2:
                self.haplotype2.append(tracts(anc, startBP, startMorgan))
                self.haplotype2[-1].setEnd(endBP, endMorgan)
            else:
                if self.haplotype2[-1].isTheSameAncestry(anc):
                    self.haplotype2[-1].setEnd(endBP, endMorgan)
                else:
                    #self.haplotype2[-1].setEnd(endBP, endMorgan)
                    self.haplotype2.append(tracts(anc, startBP, startMorgan))
                    self.haplotype2[-1].setEnd(endBP, endMorgan)

    def printTracts(self):
        print("\t Haplotype1 :")
        for tract in self.haplotype1:
            tract.printData()
        getchar()
        print("\t Haplotype2 :")
        for tract in self.haplotype2:
            tract.printData()
        getchar()

class tracts:
    def __init__(self, pop, BPstart, cMStart):
        self.pop = pop
        self.BPStart = BPstart
        self.cMStart = cMStart
        self.BPEnd = BPstart
        self.cMEnd = cMStart

    def getAncestry(self):
        return self.pop

    def getStartBP(self):
        return self.BPStart

    def getEndBP(self):
        return self.BPEnd

    def getcMStart(self):
        return self.cMStart

    def getcMEnd(self):
        return self.cMEnd

    def setEnd(self, BPEnd, cMEnd):
        self.BPEnd=BPEnd
        self.cMEnd=cMEnd

    def isTheSameAncestry(self, anc):
        if self.pop == anc:
            return True
        return False

    def printData(self):
        print("\t\t=========== Tract "+self.pop+" ============")
        print("\t\tStart (bp/cM): "+str(self.BPStart)+"/"+str(self.cMStart))
        print("\t\tEnd (bp/cM): " +str(self.BPEnd)+ "/" +str(self.cMEnd))

def readMSP(file):
    file = open(file, "r")

    mspDict = {}
    lineNumber = 0

    for line in file:
        if lineNumber > 1:
            splitted = line.split("\t")
            chr = splitted[0].replace("chr","")
            startBP = float(splitted[1])
            endBP = float(splitted[2])
            startMorgan = float(splitted[3])
            endMorgan = float(splitted[4])

            if chr not in mspDict:
                mspDict[chr] = {}
            mspDict[chr][lineNumber] = {}
            mspDict[chr][lineNumber]["startBP"] = startBP
            mspDict[chr][lineNumber]["endBP"] = endBP
            mspDict[chr][lineNumber]["startMorgan"] = startMorgan
            mspDict[chr][lineNumber]["endMorgan"] = endMorgan

        lineNumber = lineNumber + 1
    return mspDict

def readIBDFiles(db, pop, outname, removed):
    IBD = db.getIBD()
    lineNumber = 0

    fileOutput = open(outname, "w")
    fileRemoved = open(outname+"_removed", "w")

    with gzip.open(IBD, 'rb') as file:
        for line in file:
            lineNumber = lineNumber + 1
            splitted = line.decode().split()
            ind1 = splitted[0]
            ind2 = splitted[2]

            if removed and (ind1 not in pop or ind2 not in pop):
                #print(f"Line {lineNumber}: ", end = "")
                # if ind1 not in pop:
                #     print(f"{ind1}", end="")
                # if ind2 not in pop:
                #     print(f"{ind2}", end="")
                # print(" ")
                fileRemoved.write(f"{lineNumber}\n")
            else:
                hapInd1 = splitted[1]
                hapInd2 = splitted[3]
                chr = splitted[4]
                posBPStart = int(splitted[5])
                posBPEnd = int(splitted[6])
                sizeBP = float(splitted[7])

                firstCols = f"{ind1}\t{hapInd1}\t{ind2}\t{hapInd2}\t{chr}\t{posBPStart}\t{posBPEnd}\t{sizeBP}\t"

                tractsInd1 = pop[ind1].getTracts(chr, hapInd1, posBPStart, posBPEnd)
                tractsInd2 = pop[ind2].getTracts(chr, hapInd2, posBPStart, posBPEnd)

                #print(f"The first cols: {firstCols}")
                #print(f"Tract ind 1")
                #for tract in tractsInd1:
                #    tract.printData()
                #getchar()
                #print(f"Tract ind 2")
                #for tract in tractsInd2:
                #    tract.printData()
                #getchar()

                index1 = 0
                index2 = 0
                while index1 < len(tractsInd1) and index2 < len(tractsInd2):
                    startInd1 = startWithTheIBD(tractsInd1[index1].getStartBP(), posBPStart)
                    startInd2 = startWithTheIBD(tractsInd2[index2].getStartBP(), posBPStart)

                    endInd1 = endWithTheIBD(tractsInd1[index1].getEndBP(), posBPEnd)
                    endInd2 = endWithTheIBD(tractsInd2[index2].getEndBP(), posBPEnd)

                    ancInd1 = tractsInd1[index1].getAncestry()
                    ancInd2 = tractsInd2[index2].getAncestry()

                    if startInd1 > startInd2:
                        startToPrint = startInd1
                    else:
                        startToPrint = startInd2

                    if endInd1 < endInd2:
                        endToPrint = endInd1
                        index1 = index1 + 1
                    elif endInd1 > endInd2:
                        endToPrint = endInd2
                        index2 = index2 + 1
                    else:
                        endToPrint = endInd2
                        index1 = index1 + 1
                        index2 = index2 + 1

                    fileOutput.write(f"{firstCols}\t{startToPrint}\t{endToPrint}\t{ancInd1}\t{ancInd2}\n")
                    #getchar()
    fileOutput.close()
    fileRemoved.close()


def startWithTheIBD(startLA, startIBD):
    if startLA < startIBD:
        return startIBD
    return startLA


def endWithTheIBD(endLA, endIBD):
    if endLA > endIBD:
        return endIBD
    return endLA


def readLocalAncestryFiles(db, cutoff):
    fb,msp = db.getLocalAncestryFiles()

    mspDict = readMSP(msp)

    fbFile = open(fb, "r")
    lineNumber = 0

    headerDict = {}
    pop = {}

    previousBP = 0
    previousMorgan = 0

    for line in fbFile:
        #print(f"line {lineNumber}")
        if lineNumber > 1: #Other lines: data
            splitted = line.split("\t")

            chr = splitted[0].replace("chr", "")
            posBPStart = mspDict[chr][lineNumber]["startBP"]
            posBPEnd = mspDict[chr][lineNumber]["endBP"]
            posMorganStart = mspDict[chr][lineNumber]["startMorgan"]
            posMorganEnd = mspDict[chr][lineNumber]["endMorgan"]

            #Get the column X to X + #parental
            for i in range(4, len(splitted), len(parental)):
                #Get the biggest CV and the index
                bestCV = float(splitted[i])
                index = i
                for j in range(1, len(parental)):
                    if bestCV < float(splitted[j+i]):
                        bestCV = float(splitted[j+i])
                        index = j+i

                indID = headerDict[index]['ID']
                haplotype = headerDict[index]['Hap']
                if bestCV >= cutoff:
                    anc = headerDict[index]['Ancestry']
                else:
                    anc = "-"
                pop[indID].insertTract(chr, posBPStart, posMorganStart, posBPEnd, posMorganEnd, haplotype, anc)

        elif lineNumber == 1: #Second line: header with individual ID and haplotype
            header = line.split("\t")
            for i in range(4, len(header)):
                splitted = header[i].split(":::")

                headerDict[i] = {}
                headerDict[i]['ID'] = splitted[0]
                headerDict[i]['Hap'] = int(splitted[1].replace("hap", ""))
                headerDict[i]['Ancestry'] = splitted[2]

                if splitted[0] not in pop:
                    pop[splitted[0]] = genome()

        elif lineNumber == 0: #First line, with parental populations
            parental = line.strip().split("\t")
            parental.remove(parental[0])

        lineNumber = lineNumber + 1

#    for ind in pop:
#        print(f"Tracts from {ind}")
#        pop[ind].printChr()
#        getchar()
    return pop



def creatingOutputFolder(folder):
    os.makedirs(folder, exist_ok=True)

def readDBFile(inputFile):
    file = open(inputFile, "r")

    databases = {}
    for line in file:
        if line[0] != "" and line[0] != "\n":
            if line[0] != "#":  # Se nao for comentario
                striped = removeNonPrintable(line)
                fields = striped.split("\t")

                if fields[0] in databases:
                    finish("There is multiples databases with the same ID (" + fields[0] + ")")
                else:
                    databases[fields[0]] = DB(fields[0], fields[1], fields[2], fields[3])
    return databases

#===================== Utils =======================

def removeNonPrintable(string):
    new = string.strip("\n")
    new = new.strip("\r")

    return new

def finish(string):
    print(string)
    exit()

def getchar():
    c = sys.stdin.read(1)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='3A script: Automated Ancestry Analysis Script')

    required = parser.add_argument_group("Required arguments")
    required.add_argument('-d', '--database', help='File with the description of the databases', required=True)
    required.add_argument('-f', '--folder', help='Folder to store the intermediary files and output files',
                          required=True)
    required.add_argument('-c', '--cutoff', help='Cutoff to Local ancestry (default = 0.9)',
                          required=False, default = 0.9)
    required.add_argument('-r', '--removed', help='Print removed lines from IBD file',
                          required=False, default=False)
    
    args = parser.parse_args()

    folder = args.folder
    creatingOutputFolder(folder)
    
    inputFile = args.database
    databases = readDBFile(inputFile)

    cutoff = float(args.cutoff)

    removed = args.removed

    for db in databases:
        #pop = {}
        pop = readLocalAncestryFiles(databases[db], cutoff)
        readIBDFiles(databases[db], pop, f"{folder}/{db}_out", removed)
    