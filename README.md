# bpmn2-petrinet-tools

Try it out. Works for well-formed BPMNs only. Works for simple diagrams.

```
./traces Simple1.bpmn
./convert Simple1.bpmn
./visual Simple1.bpmn |dot -Tsvg > test.svg; eog test.svg
./reach Simple1.bpmn
```
